use crate::utils::{
    constants::{INFURA_GATEWAY, TRIPLEA_URI},
    lens::handle_lens_account,
    types::{AgentManager, MessageExample, Text, TripleAAgent},
};
use chrono::Utc;
use ethers::types::U256;
use rand::{rngs::StdRng, Rng, SeedableRng};
use regex::Regex;
use reqwest::Client;
use serde_json::{json, Value};
use std::{collections::HashMap, error::Error};

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
