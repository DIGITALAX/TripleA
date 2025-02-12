use chrono::Utc;
use dotenv::{dotenv, var};
use futures_util::StreamExt;
use rand::{
    rngs::StdRng,
    {Rng, SeedableRng},
};
use reqwest::Client;
use serde_json::{from_str, json, to_string_pretty, Map, Value};
use std::{collections::HashMap, error::Error, net::SocketAddr, sync::Arc, time::Duration};
use tokio::{
    fs::{File, OpenOptions},
    io::{AsyncReadExt, AsyncWriteExt},
    net::{TcpListener, TcpStream},
    spawn,
    sync::RwLock,
};
use tokio_tungstenite::{
    accept_hdr_async,
    tungstenite::{
        handshake::server::{ErrorResponse, Request, Response},
        Message,
    },
};
use tungstenite::http::method;
use utils::{
    constants::{AGENT_INTERFACE_URL, TRIPLEA_URI},
    contracts::configure_key,
    lens::handle_lens_account,
    types::*,
};
mod classes;
mod utils;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
    dotenv().ok();

    let render_key = var("RENDER_KEY").expect("No Render Key");
    let port: String = var("PORT").unwrap_or_else(|_| "10000".to_string());
    let port: u16 = port.parse::<u16>().expect("Invalid Port");
    let addr = format!("0.0.0.0:{}", port);
    let addr: SocketAddr = addr.parse().expect("Invalid Address");
    let listener = TcpListener::bind(&addr)
        .await
        .expect("Couldn't connect address");

    let agent_map = match handle_agents().await {
        Ok(agents) => agents,
        Err(_) => HashMap::new(),
    };

    let agent_map = Arc::new(RwLock::new(agent_map));
    let agent_map_clone = agent_map.clone();
    spawn(activity_loop(agent_map_clone));

    while let Ok((stream, _)) = listener.accept().await {
        let render_clone = render_key.clone();
        let agent_map_clone = agent_map.clone();
        spawn(async move {
            if let Err(err) = handle_connection(stream, render_clone, agent_map_clone).await {
                if !err.to_string().contains("Handshake not finished")
                    && !err.to_string().contains("Unsupported HTTP method used")
                {
                    eprintln!("Error managing the connection: {}", err);
                } else {
                    eprintln!("Debug: {}", err);
                }
            }
        });
    }

    Ok(())
}

async fn handle_connection(
    stream: TcpStream,
    render_key: String,
    agents: Arc<RwLock<HashMap<u32, AgentManager>>>,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let ws_stream = accept_hdr_async(stream, |req: &Request, respuesta: Response| {
        if req.method() != method::Method::GET && req.method() != method::Method::HEAD {
            return Err(ErrorResponse::new(Some(
                "HTTP method not supported".to_string(),
            )));
        }

        if req.method() == method::Method::GET {
            let uri = req.uri();
            let query: Option<&str> = uri.query();
            let origen: Option<&hyper::header::HeaderValue> = req.headers().get("origin");

            if let Some(query) = query {
                let key_from_client = query.split('=').nth(1);
                if let Some(key) = key_from_client {
                    if key.trim_end_matches("&EIO") == render_key.trim() {
                        if let Some(origen) = origen {
                            match origen.to_str() {
                                Ok(origen_str) => {
                                    if origen_str == AGENT_INTERFACE_URL {
                                        return Ok(respuesta);
                                    } else {
                                        return Err(ErrorResponse::new(Some(
                                            "Forbidden".to_string(),
                                        )));
                                    }
                                }
                                Err(e) => {
                                    eprintln!("Error processing origin: {:?}", e);
                                    Err(ErrorResponse::new(Some(
                                        "Invalid origin header".to_string(),
                                    )))
                                }
                            }
                        } else {
                            return Err(ErrorResponse::new(Some("Forbidden".to_string())));
                        }
                    } else {
                        return Err(ErrorResponse::new(Some("Forbidden".to_string())));
                    }
                } else {
                    return Err(ErrorResponse::new(Some("Bad Request".to_string())));
                }
            } else {
                return Err(ErrorResponse::new(Some("Bad Request".to_string())));
            }
        } else {
            return Ok(respuesta);
        }
    })
    .await?;

    let (_, mut read) = ws_stream.split();

    while let Some(Ok(msg)) = read.next().await {
        match msg {
            Message::Text(text) => {
                if let Ok(parsed) = from_str::<Value>(&text) {
                    if let Some(message_type) = parsed.get("type").and_then(Value::as_str) {
                        if message_type == "new_agent" {
                            if let (
                                Some(public_address),
                                Some(encryption_details),
                                Some(id),
                                Some(title),
                                Some(bio),
                                Some(lore),
                                Some(knowledge),
                                Some(adjectives),
                                Some(message_examples),
                                Some(style),
                                Some(cover),
                                Some(custom_instructions),
                                Some(account_address),
                                Some(model),
                                Some(feeds),
                            ) = (
                                parsed["publicAddress"].as_str(),
                                parsed["encryptionDetails"].as_str(),
                                parsed["id"].as_u64().map(|v| v.to_string()),
                                parsed["title"].as_str(),
                                parsed["bio"].as_str(),
                                parsed["lore"].as_str(),
                                parsed["knowledge"].as_str(),
                                parsed["adjectives"].as_str(),
                                parsed["messageExamples"].as_array(),
                                parsed["style"].as_str(),
                                parsed["model"].as_str(),
                                parsed["cover"].as_str(),
                                parsed["customInstructions"].as_str(),
                                parsed["accountAddress"].as_str(),
                                parsed["feeds"].as_array(),
                            ) {
                                let private_key = match configure_key(encryption_details) {
                                    Ok(private_key) => private_key,
                                    Err(err) => {
                                        eprintln!("Error in decrypting private key {}", err);
                                        "no_key".to_string()
                                    }
                                };

                                if private_key == "no_key".to_string() {
                                    return Ok(());
                                }
                                let new_id: u32 = id.parse().expect("Error converting id to u32");
                                println!("private_key for agent_{}: {:?}\n\n", private_key, new_id);

                                let clock = {
                                    let agents_snapshot = agents.read().await;
                                    let mut rng = StdRng::from_entropy();
                                    let mut clock;
                                    loop {
                                        let random_hour = rng.gen_range(0..5);
                                        let random_minute = rng.gen_range(0..60);
                                        let random_second = rng.gen_range(0..60);
                                        clock =
                                            random_hour * 3600 + random_minute * 60 + random_second;

                                        if !agents_snapshot.values().any(|agent| {
                                            let agent_clock = agent.agent.clock;
                                            (clock as i32 - agent_clock as i32).abs() < 60
                                        }) {
                                            break;
                                        }
                                    }
                                    clock
                                };
                                let mut agents_write = agents.write().await;

                                let mut env_file = OpenOptions::new()
                                    .append(true)
                                    .create(true)
                                    .open(".env")
                                    .await
                                    .expect("Can't open .env");

                                let metadata =
                                    env_file.metadata().await.expect("Can't read metadata");
                                if metadata.len() > 0 {
                                    env_file
                                        .write_all(b"\n")
                                        .await
                                        .expect("Error adding newline to .env");
                                }

                                let entry = format!("ID_{}={}\n", new_id.to_string(), private_key);
                                env_file
                                    .write_all(entry.as_bytes())
                                    .await
                                    .expect("Error writing to the .env");

                                let mut existing_data = Map::new();
                                if let Ok(mut file) = File::open("var/data/data.json")
                                    //  open("/var/data/data.json")
                                    .await
                                {
                                    let mut content = String::new();
                                    file.read_to_string(&mut content).await.unwrap();
                                    existing_data =
                                        from_str(&content).unwrap_or_else(|_| Map::new());
                                }

                                existing_data.insert(
                                    format!("ID_{}", new_id.to_string()),
                                    json!(encryption_details),
                                );

                                println!(
                                    "Attempting to create or write to var/data/data.json agent_{}",
                                    new_id
                                );
                                let file = OpenOptions::new()
                                    .write(true)
                                    .create(true)
                                    .open("var/data/data.json")
                                    // .open("/var/data/data.json")
                                    .await;

                                match file {
                                    Ok(mut file) => {
                                        let data = to_string_pretty(&existing_data)
                                            .unwrap_or_else(|_| String::new());
                                        file.write_all(data.as_bytes()).await.unwrap_or_else(
                                            |err| eprintln!("Error writing: {:?}", err),
                                        );
                                        let mut all_feeds: Vec<String> = Vec::new();
                                        for value in feeds {
                                            if let Some(string_value) = value.as_str() {
                                                all_feeds.push(string_value.to_string());
                                            }
                                        }
                                        let new_agent = AgentManager::new(&TripleAAgent {
                                            id: new_id,
                                            name: title.to_string(),
                                            bio: bio.to_string(),
                                            lore: lore.to_string(),
                                            adjectives: adjectives.to_string(),
                                            style: style.to_string(),
                                            knowledge: knowledge.to_string(),
                                            message_examples: message_examples
                                                .iter()
                                                .map(|v| {
                                                    v.as_array()
                                                        .unwrap_or(&vec![])
                                                        .iter()
                                                        .map(|msg| MessageExample {
                                                            user: msg["user"]
                                                                .as_str()
                                                                .unwrap_or("")
                                                                .to_string(),
                                                            content: Text {
                                                                text: msg["content"]["text"]
                                                                    .as_str()
                                                                    .unwrap_or("")
                                                                    .to_string(),
                                                            },
                                                        })
                                                        .collect::<Vec<MessageExample>>()
                                                })
                                                .collect::<Vec<Vec<MessageExample>>>(),
                                            model: model.to_string(),
                                            cover: cover.to_string(),
                                            custom_instructions: custom_instructions.to_string(),
                                            wallet: public_address.to_string(),
                                            clock,
                                            last_active_time: Utc::now().timestamp() as u32,
                                            account_address: account_address.to_string(),
                                            feeds: all_feeds,
                                        });

                                        match new_agent {
                                            Some(agent) => {
                                                agents_write.insert(new_id, agent);
                                                println!(
                                                    "Agent added at address: {}",
                                                    public_address
                                                );
                                            }
                                            None => {
                                                eprintln!(
                                                    "Agent not added at address: {}",
                                                    public_address
                                                );
                                            }
                                        }
                                    }
                                    Err(err) => {
                                        eprintln!("Failed to open file: {:?}", err);
                                    }
                                }
                            } else {
                                eprintln!("Agent data not parsed");
                            }
                        } else {
                            eprintln!("Type not found.");
                        }
                    } else {
                        eprintln!("Message not recognised.");
                    }
                }
            }
            _ => {
                eprintln!("Message type not supported: {:?}", msg);
            }
        }
    }
    Ok(())
}

async fn activity_loop(agents: Arc<RwLock<HashMap<u32, AgentManager>>>) {
    loop {
        let agent_ids: Vec<u32>;

        {
            let agents_guard = agents.read().await;
            agent_ids = agents_guard
                .iter()
                // .filter(|(_, manager)| should_trigger(&manager.agent))
                .map(|(&id, _)| id)
                .collect();
        }

        println!("Agents to trigger {}", agent_ids.len());

        for id in agent_ids {
            let agents_clone = agents.clone();

            tokio::spawn(async move {
                let maybe_agent_manager = {
                    let mut agents_guard = agents_clone.write().await;
                    agents_guard.remove(&id)
                };

                if let Some(mut agent_manager) = maybe_agent_manager {
                    if let Err(err) = agent_manager.resolve_activity().await {
                        eprintln!("Error resolving activity for agent {}: {:?}", id, err);
                    }

                    let mut agents_guard = agents_clone.write().await;
                    agents_guard.insert(id, agent_manager);
                }
            });
        }
        tokio::time::sleep(Duration::from_secs(5000)).await;
        // tokio::time::sleep(Duration::from_secs(500)).await;
    }
}

fn should_trigger(agent: &TripleAAgent) -> bool {
    let now_seconds = Utc::now().timestamp() as u32;
    let day_seconds = now_seconds % 18000;
    let diff = (agent.clock as i32 - day_seconds as i32).abs();

    diff <= 500
}

async fn handle_agents() -> Result<HashMap<u32, AgentManager>, Box<dyn Error + Send + Sync>> {
    let client = Client::new();

    let query = json!({
        "query": r#"
        query {
            agentCreateds(first: 100) {
                wallets
                SkyhuntersAgentManager_id
                creator
                metadata {
                    title
                    bio
                    lore
                    adjectives
                    style
                    knowledge
                    messageExamples
                    model
                    cover
                    customInstructions
                    feeds
                }
            }
        }
        "#,
    });

    let res = client.post(TRIPLEA_URI).json(&query).send().await;

    match res {
        Ok(response) => {
            let parsed: Value = response.json().await?;
            println!("parsed {:?}", parsed);
            let empty_vec = vec![];
            let agent_createds = parsed["data"]["agentCreateds"]
                .as_array()
                .unwrap_or(&empty_vec);

            let mut agents_snapshot: HashMap<u32, AgentManager> = HashMap::new();

            for agent_created in agent_createds {
                let new_id: u32 = agent_created["SkyhuntersAgentManager_id"]
                    .as_str()
                    .unwrap_or("0")
                    .parse()
                    .map_err(|_| "Failed to parse ID")?;

                let mut rng = StdRng::from_entropy();
                let mut clock;
                loop {
                    let random_hour = rng.gen_range(0..5);
                    let random_minute = rng.gen_range(0..60);
                    let random_second = rng.gen_range(0..60);
                    clock = random_hour * 3600 + random_minute * 60 + random_second;

                    if !agents_snapshot.values().any(|agent| {
                        let agent_clock = agent.agent.clock;
                        (clock as i32 - agent_clock as i32).abs() < 60
                    }) {
                        break;
                    }
                }
                let wallet = agent_created["wallets"]
                    .as_array()
                    .unwrap_or(&vec![])
                    .get(0)
                    .and_then(|w| w.as_str())
                    .unwrap_or("")
                    .to_string();
                let account_address = handle_lens_account(&wallet, false)
                    .await
                    .unwrap_or_default();

                let manager = AgentManager::new(&TripleAAgent {
                    id: new_id,
                    name: agent_created["metadata"]["title"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    bio: agent_created["metadata"]["bio"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    lore: agent_created["metadata"]["lore"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    adjectives: agent_created["metadata"]["adjectives"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    style: agent_created["metadata"]["style"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    knowledge: agent_created["metadata"]["knowledge"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    message_examples: agent_created["metadata"]["message_examples"]
                        .as_array()
                        .unwrap_or(&vec![])
                        .iter()
                        .map(|v| {
                            v.as_array()
                                .unwrap_or(&vec![])
                                .iter()
                                .map(|con| {
                                    let parsed_con: MessageExample =
                                        serde_json::from_str(con.as_str().unwrap_or("{}"))
                                            .unwrap_or(MessageExample {
                                                user: "".to_string(),
                                                content: Text {
                                                    text: "".to_string(),
                                                },
                                            });

                                    parsed_con
                                })
                                .collect::<Vec<MessageExample>>()
                        })
                        .collect::<Vec<Vec<MessageExample>>>(),
                    model: agent_created["metadata"]["model"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    cover: agent_created["metadata"]["cover"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    custom_instructions: agent_created["metadata"]["customInstructions"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    feeds: agent_created["metadata"]["feeds"]
                        .as_array()
                        .unwrap_or(&Vec::new())
                        .iter()
                        .filter_map(|value| value.as_str().map(|s| s.to_string()))
                        .collect(),
                    wallet,
                    clock,
                    last_active_time: Utc::now().timestamp() as u32,
                    account_address,
                });

                match manager {
                    Some(man) => {
                        agents_snapshot.insert(new_id, man);
                    }
                    None => {
                        eprintln!("Agent Not Added at id {}", new_id)
                    }
                }
            }
            Ok(agents_snapshot)
        }
        Err(err) => Err(Box::new(err)),
    }
}
