use std::{env, error::Error, io, sync::Arc, time::Duration};

use ethers::{
    contract::{ContractInstance, FunctionCall},
    core::k256::ecdsa::SigningKey,
    middleware::{Middleware, SignerMiddleware},
    providers::{Http, Provider},
    signers::Wallet,
    types::{Address, Eip1559TransactionRequest, NameOrAddress, H256, U256},
};
use reqwest::Client;
use serde_json::{json, to_string, Value};

use crate::utils::{
    constants::{BONSAI, COLLECTION_MANAGER, GRASS, LENS_CHAIN_ID, MONA, REMIX_FEED, TRIPLEA_URI},
    ipfs::upload_ipfs,
    lens::make_publication,
    models::{
        call_drop_details_claude, call_drop_details_openai, call_image_details_claude,
        call_image_details_openai, call_prompt_claude, call_prompt_openai,
    },
    types::{Collection, CollectionInput, CollectionWorker, TripleAAgent},
};

pub async fn remix(
    agent: &TripleAAgent,
    collection: &Collection,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match if agent.model == "Claude" {
        call_prompt_claude(&collection.image, &collection.description).await
    } else {
        call_prompt_openai(&collection.image, &collection.description).await
    } {
        Ok((image_prompt, model)) => {
            call_comfy(
                &image_prompt,
                &collection.image,
                &model,
                collection.collection_id,
                agent.id,
            )
            .await?
        }
        Err(err) => {
            eprintln!("Error with image prompt: {}", err)
        }
    }

    Ok(())
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
    agent: &TripleAAgent,
    remix_collection_id: &str,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match get_drop_details(
        remix_collection_id,
        description,
        agent.id,
        &agent.model,
        image,
    )
    .await
    {
        Ok((drop_metadata, drop_id)) => {
            match upload_ipfs(to_string(&json!({
                "title": title,
                "description": description,
                "image": image
            }))?)
            .await
            {
                Ok(response) => {
                    let method = collection_manager_contract.method::<(
                        CollectionInput,
                        Vec<CollectionWorker>,
                        String,
                        U256,
                    ), H256>(
                        "create",
                        (
                            CollectionInput {
                                customInstructions: vec![agent.description.to_string()],
                                tokens: vec![
                                    MONA.to_string(),
                                    GRASS.to_string(),
                                    BONSAI.to_string(),
                                ],
                                prices,
                                agentIds: vec![U256::from(agent.id)],
                                metadata: format!("ipfs://{}", response.Hash),
                                collectionType: 0,
                                amount,
                                fulfillerId: U256::from(0),
                                remix: true,
                            },
                            vec![CollectionWorker {
                                publish: true,
                                publishFrequency: U256::from(1),
                                remix: false,
                                remixFrequency: U256::from(0),
                                lead: false,
                                leadFrequency: U256::from(0),
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

async fn call_comfy(
    prompt: &str,
    init_image: &str,
    model: &str,
    remix_id: U256,
    agent_id: u32,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let comfy_key = env::var("COMFY_KEY").expect("COMFY_KEY no está configurada en .env");

    let cliente = Client::builder()
        .danger_accept_invalid_certs(true)
        .danger_accept_invalid_hostnames(true)
        .timeout(Duration::from_secs(10000))
        .connect_timeout(Duration::from_secs(10000))
        .read_timeout(Duration::from_secs(10000))
        .pool_idle_timeout(Duration::from_secs(10000))
        .pool_max_idle_per_host(10000)
        .use_rustls_tls()
        .no_gzip()
        .no_brotli()
        .no_deflate()
        .no_proxy()
        .build()?;
    let payload_inicial = serde_json::json!({
        "api_key": comfy_key,
        "init_image": init_image.trim(),
        "prompt": prompt,
        "model": model,
        "remix_id": remix_id,
        "agent_id": agent_id
    });

    let res_inicial = cliente
        .post("https://glorious-eft-deeply.ngrok-free.app/run_comfy")
        .header("Content-Type", "application/json; charset=UTF-8")
        .json(&payload_inicial)
        .send()
        .await?;

    if res_inicial.status() == 200 {
        println!("Successfully sent to Comfy queue");
        Ok(())
    } else {
        return Err(Box::new(std::io::Error::new(
            std::io::ErrorKind::Other,
            format!("Error in sending to Comfy {:?}", res_inicial.status()),
        )));
    }
}

pub async fn receive_comfy(
    image: &str,
    remix_collection_id: &str,
    agent: &TripleAAgent,
    collection_manager_contract: Arc<
        ContractInstance<
            Arc<SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>>,
            SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>,
        >,
    >,
    auth_tokens: &str,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match if agent.model == "Claude" {
        call_image_details_claude(&image).await
    } else {
        call_image_details_openai(&image).await
    } {
        Ok((title, description, amount, prices)) => {
            let _ = mint_collection(
                &description,
                &image,
                &title,
                amount,
                collection_manager_contract,
                prices,
                &agent,
                remix_collection_id,
            )
            .await;

            let _ = make_publication(
                &description,
                agent.id,
                &auth_tokens,
                Some(REMIX_FEED.to_string()),
            )
            .await;
        }
        Err(err) => {
            eprintln!("Error with creating remix: {}", err)
        }
    }

    Ok(())
}

async fn get_drop_details(
    remix_collection_id: &str,
    remix_collection_description: &str,
    agent_id: u32,
    model: &str,
    image: &str,
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
                match if model == "Claude" {
                    call_drop_details_claude(&remix_collection_description, image).await
                } else {
                    call_drop_details_openai(&remix_collection_description, image).await
                } {
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
