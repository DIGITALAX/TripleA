use std::{env, error::Error, io, str::FromStr, sync::Arc};

use ethers::{
    contract::{ContractInstance, FunctionCall},
    core::k256::ecdsa::SigningKey,
    middleware::{Middleware, SignerMiddleware},
    providers::{Http, Provider},
    signers::Wallet,
    types::{Address, Eip1559TransactionRequest, NameOrAddress, H160, H256, U256},
};
use rand::{thread_rng, Rng};
use reqwest::Client;
use serde_json::{json, to_string, Value};
use uuid::Uuid;

use crate::utils::{
    constants::{
        BONSAI, COLLECTION_MANAGER, LENS_CHAIN_ID, MONA, NEGATIVE_PROMPT, REMIX_FEED,
        STYLE_PRESETS, TRIPLEA_URI, VENICE_API,
    },
    helpers::validate_and_fix_prices,
    ipfs::{upload_image_to_ipfs, upload_ipfs, upload_lens_storage},
    lens::make_publication,
    types::{
        Collection, CollectionInput, CollectionWorker, Content, Image, Publication, SavedTokens,
        TripleAAgent,
    },
    venice::{call_drop_details, call_image_details, call_prompt},
};

pub async fn remix(
    agent: &TripleAAgent,
    collection: &Collection,
    tokens: Option<SavedTokens>,
    collection_manager_contract: Arc<
        ContractInstance<
            Arc<SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>>,
            SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>,
        >,
    >,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match call_prompt(&collection.description, &agent.model).await {
        Ok((prompt, model)) => {
            let venice_key =
                env::var("VENICE_KEY").expect("VENICE_KEY no está configurada en .env");

            let client = Client::new();

            let payload_inicial = serde_json::json!({
                "model": model,
                "prompt": prompt,
                "width": 768,
                "height": 768,
                "steps": 25,
                "hide_watermark": true,
                "return_binary": false,
                "cfg_scale": 3.5,
                "style_preset": STYLE_PRESETS[thread_rng().gen_range(0..3)],
                "negative_prompt": NEGATIVE_PROMPT,
                "safe_mode": false
            });

            let response = client
                .post(format!("{}image/generate", VENICE_API))
                .header("Content-Type", "application/json")
                .header("Authorization", format!("Bearer {}", venice_key))
                .json(&payload_inicial)
                .send()
                .await?;

            if response.status() == 200 {
                let json: Value = response.json().await?;
                let images = json
                    .get("images")
                    .and_then(|v| v.as_array())
                    .cloned()
                    .unwrap_or_else(Vec::new);
                let image = images
                    .first()
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                match call_image_details(&agent.model).await {
                    Ok((title, description, amount, prices, mona_price, bonsai_price)) => {
                        match upload_image_to_ipfs(&image).await {
                            Ok(ipfs) => {
                                let _ = mint_collection(
                                    &description,
                                    &format!("ipfs://{}", ipfs.Hash),
                                    &title,
                                    amount,
                                    collection_manager_contract,
                                    prices,
                                    mona_price,
                                    bonsai_price,
                                    &agent,
                                    collection.collection_id,
                                    &agent.model,
                                )
                                .await;

                                    let focus = String::from("IMAGE");
                                    let schema = "https://json-schemas.lens.dev/posts/image/3.0.0.json"
                                        .to_string();
                                    let tags = vec![
                                        "tripleA".to_string(),
                                        title.replace(" ", "").to_lowercase(),
                                    ];

                                    let publication = Publication {
                                        schema,
                                        lens: Content {
                                            mainContentFocus: focus,
                                            title,
                                            content: description,
                                            id: Uuid::new_v4().to_string(),
                                            locale: "en".to_string(),
                                            tags,
                                            image: Some(Image {
                                                tipo: "image/png".to_string(),
                                                item: format!("ipfs://{}", ipfs.Hash),
                                            }),
                                        },
                                    };

                                    let publication_json = to_string(&publication)?;

                                    let content = match upload_lens_storage(publication_json).await {
                                        Ok(con) => con,
                                        Err(e) => {
                                            eprintln!("Error uploading content to Lens Storage: {}", e);
                                            return Err(Box::new(io::Error::new(
                                                io::ErrorKind::Other,
                                                format!(
                                                    "Error uploading content to Lens Storage: {}",
                                                    e
                                                ),
                                            )));
                                        }
                                    };


                                   let _ =   make_publication(
                                        &content,
                                        agent.id,
                                        &tokens.as_ref().unwrap().tokens.access_token,
                                        // Some(REMIX_FEED.to_string()),
                                        None
                                    )
                                    .await;

                                Ok(())
                            }
                            Err(err) => {
                                return Err(Box::new(std::io::Error::new(
                                    std::io::ErrorKind::Other,
                                    format!("Error in uploading image to IPFS {:?}", err),
                                )));
                            }
                        }
                    }
                    Err(err) => {
                        return Err(Box::new(std::io::Error::new(
                            std::io::ErrorKind::Other,
                            format!("Error with creating remix {:?}", err),
                        )));
                    }
                }
            } else {
                return Err(Box::new(std::io::Error::new(
                    std::io::ErrorKind::Other,
                    format!("Error in sending to Venice {:?}", response.status()),
                )));
            }
        }
        Err(err) => {
            eprintln!("Error with image prompt: {}", err);
            Ok(())
        }
    }
}

async fn mint_collection(
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
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match get_drop_details(remix_collection_id, description, agent.id, image, &model).await {
        Ok((drop_metadata, drop_id)) => {
            match upload_ipfs(to_string(&json!({
                "title": title,
                "description": description,
                "image": image
            }))?)
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
                                // prices: vec![U256::from_dec_str("300000000000000000000").unwrap(),U256::from_dec_str("300000000000000000000").unwrap()],
                                agentIds: vec![U256::from(agent.id)],
                                metadata: format!("ipfs://{}", response.Hash),
                                collectionType: 0u8,
                                amount,
                                fulfillerId: U256::from(0),
                                remixable: true,
                                remixId: remix_collection_id,
                            },
                            vec![CollectionWorker {
                                instructions: agent.custom_instructions.to_string(),
                                publishFrequency: U256::from(1),
                                remixFrequency: U256::from(0),
                                leadFrequency: U256::from(0),
                                publish: true,
                                remix: false,
                                lead: false,
                            }],
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
