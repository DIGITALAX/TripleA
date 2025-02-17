use crate::utils::{
    constants::{BONSAI, COLLECTION_MANAGER, INFURA_GATEWAY, LENS_CHAIN_ID, MONA, TRIPLEA_URI},
    ipfs::upload_ipfs,
    lens::handle_lens_account,
    types::{
        AgentManager, CollectionInput, CollectionWorker, MessageExample, PriceCollection, Text,
        TripleAAgent,
    },
    venice::call_drop_details,
};
use chrono::Utc;
use ethers::{
    contract::{ContractInstance, FunctionCall},
    core::k256::ecdsa::SigningKey,
    middleware::SignerMiddleware,
    providers::{Http, Middleware, Provider},
    signers::Wallet,
    types::{Address, Eip1559TransactionRequest, NameOrAddress, H160, H256, U256},
};
use rand::{rngs::StdRng, Rng, SeedableRng};
use regex::Regex;
use reqwest::Client;
use serde_json::{json, to_string, Value};
use std::{collections::HashMap, error::Error, io, str::FromStr, sync::Arc};

pub fn extract_values_prompt(
    input: &str,
) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    let image_prompt_re = Regex::new(r"(?m)^Image Prompt:\s*(.+)")?;
    let model_re = Regex::new(r"(?m)^Model:\s*(.+)")?;

    let image_prompt = image_prompt_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();
    let model = model_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();

    Ok((image_prompt, model))
}

pub fn extract_values_image(
    input: &str,
    mona_price: f64,
    bonsai_price: f64,
) -> Result<(String, String, U256, Vec<U256>, f64, f64), Box<dyn Error + Send + Sync>> {
    let title_re = Regex::new(r"(?m)^Title:\s*(.+)")?;
    let description_re = Regex::new(r"(?m)^Description:\s*(.+)")?;
    let amount_re = Regex::new(r"(?m)^Amount:\s*(\d+)")?;
    let mona_re = Regex::new(r"(?m)^Mona:\s*(\d+)")?;
    let bonsai_re = Regex::new(r"(?m)^Bonsai:\s*(\d+)")?;

    let title = title_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();
    let description = description_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();
    let amount: u32 = amount_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| m.as_str().parse::<u32>().ok())
        .unwrap_or_default();

    let mona: U256 = mona_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| U256::from_dec_str(m.as_str()).ok())
        .unwrap_or(U256::zero());

    let bonsai: U256 = bonsai_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| U256::from_dec_str(m.as_str()).ok())
        .unwrap_or(U256::zero());

    Ok((
        title,
        description,
        U256::from(amount),
        vec![U256::from(mona), U256::from(bonsai)],
        mona_price,
        bonsai_price,
    ))
}

pub fn extract_values_drop(input: &str) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    let title_re = Regex::new(r"(?m)^Title:\s*(.+)")?;
    let description_re = Regex::new(r"(?m)^Description:\s*(.+)")?;

    let title = title_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();
    let description = description_re
        .captures(input)
        .and_then(|cap| cap.get(1).map(|m| m.as_str()))
        .unwrap_or_default()
        .to_string();

    Ok((title, description))
}

pub fn format_instructions(agent: &TripleAAgent) -> String {
    format!(
        r#"
Custom Instructions: {}
Lore: {}
Knowledge: {}
Style: {}
Adjectives: {}
"#,
        agent.custom_instructions, agent.lore, agent.knowledge, agent.style, agent.adjectives
    )
}

pub async fn fetch_metadata(uri: &str) -> Option<Value> {
    if let Some(ipfs_hash) = uri.strip_prefix("ipfs://") {
        let client = Client::new();
        let url = format!("{}/{}", INFURA_GATEWAY, ipfs_hash);
        if let Ok(response) = client.get(&url).send().await {
            if let Ok(json) = response.json::<Value>().await {
                return Some(json);
            }
        }
    }
    None
}

pub async fn handle_agents() -> Result<HashMap<u32, AgentManager>, Box<dyn Error + Send + Sync>> {
    let client = Client::new();

    let query = json!({
        "query": r#"
        query {
            agentCreateds(first: 100) {
                wallets
                SkyhuntersAgentManager_id
                creator
                uri
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

                let metadata = agent_created["metadata"].clone();
                let is_metadata_empty = metadata.is_null()
                    || metadata.as_object().map(|o| o.is_empty()).unwrap_or(false);

                let metadata_filled = if is_metadata_empty {
                    if let Some(uri) = agent_created["uri"].as_str() {
                        fetch_metadata(uri).await.unwrap_or(json!({}))
                    } else {
                        json!({})
                    }
                } else {
                    metadata
                };

                let manager = AgentManager::new(&TripleAAgent {
                    id: new_id,
                    name: metadata_filled["title"].as_str().unwrap_or("").to_string(),
                    bio: metadata_filled["bio"].as_str().unwrap_or("").to_string(),
                    lore: metadata_filled["lore"].as_str().unwrap_or("").to_string(),
                    adjectives: metadata_filled["adjectives"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    style: metadata_filled["style"].as_str().unwrap_or("").to_string(),
                    knowledge: metadata_filled["knowledge"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    message_examples: metadata_filled["message_examples"]
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
                    model: metadata_filled["model"]
                        .as_str()
                        .unwrap_or("dolphin-2.9.2-qwen2-72b")
                        .to_string(),
                    cover: metadata_filled["cover"].as_str().unwrap_or("").to_string(),
                    custom_instructions: metadata_filled["customInstructions"]
                        .as_str()
                        .unwrap_or("")
                        .to_string(),
                    feeds: metadata_filled["feeds"]
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

pub fn validate_and_fix_prices(prices: Vec<U256>, mona_price: f64, bonsai_price: f64) -> Vec<U256> {
    let token_prices = [mona_price, bonsai_price];
    let mut new_prices = Vec::with_capacity(2);

    for i in 0..2 {
        let mut rng = StdRng::from_entropy();
        let random_target = rng.gen_range(150.0..320.0);
        let token_amount = prices[i].as_u128() as f64 / 10f64.powi(18);
        let usd_value = token_amount * token_prices[i];

        let final_price = if usd_value < 200.0 || usd_value > 700.0 || token_amount.fract() > 0.0 {
            let target_tokens = random_target / token_prices[i];
            U256::from((target_tokens * 10f64.powi(18)) as u128)
        } else {
            prices[i]
        };

        new_prices.push(final_price);
    }

    new_prices
}

pub async fn mint_collection(
    description: &str,
    image: &str,
    title: &str,
    amount: U256,
    collection_manager_contract: Arc<
        ContractInstance<
            Arc<SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>>,
            SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>,
        >,
    >,
    prices: Vec<U256>,
    mona_price: f64,
    bonsai_price: f64,
    agent: &TripleAAgent,
    remix_collection_id: U256,
    model: &str,
    image_prompt: &str,
    image_model: &str,
    collection_type: u8,
    format: Option<String>,
    worker: bool,
    for_artist: &str,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match get_drop_details(remix_collection_id, description, agent.id, image, &model).await {
        Ok((drop_metadata, drop_id)) => {
            match upload_ipfs(if collection_type == 0u8 {
                to_string(&json!({
                    "title": title,
                    "description": description,
                    "image": image,
                    "model": image_model,
                    "prompt": image_prompt
                }))?
            } else {
                to_string(&json!({
                    "title": title,
                    "description": description,
                    "image": image,
                    "model": image_model,
                    "prompt": image_prompt,
                    "sizes": vec!["XS", "S", "M", "L", "XL", "2XL"],
                    "colors": vec!["White", "Black"],
                    "format": format.unwrap()
                }))?
            })
            .await
            {
                Ok(response) => {
                    let prices = validate_and_fix_prices(prices, mona_price, bonsai_price);
                    let method = collection_manager_contract.method::<(
                        CollectionInput,
                        Vec<CollectionWorker>,
                        String,
                        U256,
                    ), H256>(
                        "create",
                        (
                            CollectionInput {
                                tokens: vec![
                                    H160::from_str(MONA).unwrap(),
                                    H160::from_str(BONSAI).unwrap(),
                                ],
                                prices,
                                agentIds: if worker {
                                    vec![U256::from(agent.id)]
                                } else {
                                    vec![]
                                },
                                metadata: format!("ipfs://{}", response.Hash),
                                forArtist: H160::from_str(for_artist).unwrap(),
                                collectionType: collection_type,
                                amount,
                                fulfillerId: if collection_type == 0u8 {
                                    U256::from(0)
                                } else {
                                    U256::from(1)
                                },
                                remixable: true,
                                remixId: remix_collection_id,
                            },
                            if worker {
                                vec![CollectionWorker {
                                    instructions: agent.custom_instructions.to_string(),
                                    publishFrequency: U256::from(1),
                                    remixFrequency: U256::from(0),
                                    leadFrequency: U256::from(0),
                                    mintFrequency: U256::from(1),
                                    publish: true,
                                    remix: false,
                                    lead: false,
                                    mint: true,
                                }]
                            } else {
                                vec![]
                            },
                            drop_metadata,
                            drop_id,
                        ),
                    );

                    match method {
                        Ok(call) => {
                            let FunctionCall { tx, .. } = call;

                            if let Some(tx_request) = tx.as_eip1559_ref() {
                                let gas_price = U256::from(500_000_000_000u64);
                                let max_priority_fee = U256::from(25_000_000_000u64);
                                let gas_limit = U256::from(300_000);

                                let client = collection_manager_contract.client().clone();
                                let chain_id = *LENS_CHAIN_ID;
                                let req = Eip1559TransactionRequest {
                                    from: Some(agent.wallet.parse::<Address>().unwrap()),
                                    to: Some(NameOrAddress::Address(
                                        COLLECTION_MANAGER.parse::<Address>().unwrap(),
                                    )),
                                    gas: Some(gas_limit),
                                    value: tx_request.value,
                                    data: tx_request.data.clone(),
                                    max_priority_fee_per_gas: Some(max_priority_fee),
                                    max_fee_per_gas: Some(gas_price + max_priority_fee),
                                    chain_id: Some(chain_id.into()),
                                    ..Default::default()
                                };

                                let pending_tx = match client.send_transaction(req, None).await {
                                    Ok(tx) => tx,
                                    Err(e) => {
                                        eprintln!(
                                            "Error sending the transaction for payRent: {:?}",
                                            e
                                        );
                                        Err(Box::new(e))?
                                    }
                                };

                                let tx_hash = match pending_tx.confirmations(1).await {
                                    Ok(hash) => hash,
                                    Err(e) => {
                                        eprintln!("Error with transaction confirmation: {:?}", e);
                                        Err(Box::new(e))?
                                    }
                                };

                                println!("Remix Hash: {:?}", tx_hash);

                                Ok(())
                            } else {
                                eprintln!("Error in sending Transaction");
                                Err(Box::new(io::Error::new(
                                    io::ErrorKind::Other,
                                    "Error in sending Transaction",
                                )))
                            }
                        }

                        Err(err) => {
                            eprintln!("Error in create method for create collection: {:?}", err);
                            Err(Box::new(err))
                        }
                    }
                }
                Err(err) => {
                    eprintln!("Error in IPFS upload for create collection: {:?}", err);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::Other,
                        "Error in IPFS upload",
                    )))
                }
            }
        }
        Err(err) => {
            eprintln!("Error with drop details: {}", err);
            Err(Box::new(io::Error::new(
                io::ErrorKind::Other,
                "Error with drop details",
            )))
        }
    }
}

async fn get_drop_details(
    remix_collection_id: U256,
    remix_collection_description: &str,
    agent_id: u32,
    image: &str,
    model: &str,
) -> Result<(String, U256), Box<dyn Error + Send + Sync>> {
    let mut drop_metadata = String::from("");
    let mut drop_id = U256::from(0);

    let client = Client::new();

    let query = json!({
        "query": r#"
        query(TripleAAgents_id: Int!, remixId: Int!) {
            agentRemixes(first: 1, where: {
            TripleAAgents_id: $TripleAAgents_id, remixId: $remixId
            }) {
                dropId
            }
        }
        "#,
        "variables": {
            "request": {
                "TripleAAgents_id": agent_id,
                "remixId": remix_collection_id
            }
    }
    });

    let res = client.post(TRIPLEA_URI).json(&query).send().await;

    match res {
        Ok(response) => {
            let parsed: Value = response.json().await?;

            if let Some(value) = parsed["data"]["agentRemixes"]
                .as_array()
                .map(|arr| arr.first())
                .flatten()
                .and_then(|value| value.get("dropId"))
                .and_then(|drop_id| drop_id.as_str())
                .map(String::from)
            {
                let id: u32 = value.parse().expect("Error converting drop value to u32");
                drop_id = U256::from(id);
            } else {
                match call_drop_details(&remix_collection_description, &model).await {
                    Ok((title, description)) => {
                        match upload_ipfs(to_string(&json!({
                            "title": title,
                            "description": description,
                            "image": image
                        }))?)
                        .await
                        {
                            Ok(ipfs) => drop_metadata = format!("ipfs://{}", ipfs.Hash),
                            Err(err) => {
                                eprintln!("Error with IPFS upload for drop: {}", err)
                            }
                        }
                    }
                    Err(err) => {
                        eprintln!("Error with drop AI call: {}", err)
                    }
                }
            }
        }
        Err(err) => {
            eprintln!("Error with drop details: {}", err)
        }
    }

    Ok((drop_metadata, drop_id))
}

pub async fn find_collection(
    balance: U256,
    token: &str,
    artist: &str,
) -> Result<Vec<PriceCollection>, Box<dyn Error + Send + Sync>> {
    let client = Client::new();

    let query = json!({
        "query": r#"
        query($token: $String!, $artist: String!, $soldOut: Bool!, $maxPrice: Int!) {
            collectionPrices(where: { token: $token, artist: $artist, soldOut: $soldOut, price_lte: $maxPrice }, first: 100) {
                collectionId
                amount
                amountSold
            }
        }
        "#,
        "variables": {
            "request": {
                "soldOut": false,
                "maxPrice": balance,
                "artist": artist,
                "token": token
            }
        }
    });

    let res = client.post(TRIPLEA_URI).json(&query).send().await;

    match res {
        Ok(response) => {
            let parsed: Value = response.json().await?;
            let empty_vec = vec![];
            let collections_snapshot = parsed["data"]["collectionPrices"]
                .as_array()
                .unwrap_or(&empty_vec);

            let mut collections: Vec<PriceCollection> = vec![];

            for collection in collections_snapshot {
                collections.push(PriceCollection {
                    collectionId: collection["collectionId"]
                        .as_str()
                        .unwrap_or("0")
                        .parse()
                        .map_err(|_| "Failed to parse collectionId")?,
                    amount: collection["amount"]
                        .as_str()
                        .unwrap_or("0")
                        .parse()
                        .map_err(|_| "Failed to parse amount")?,
                    amountSold: collection["amountSold"]
                        .as_str()
                        .unwrap_or("0")
                        .parse()
                        .map_err(|_| "Failed to parse amountSold")?,
                })
            }
            Ok(collections)
        }
        Err(err) => Err(Box::new(err)),
    }
}
