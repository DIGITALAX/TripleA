use crate::classes::{lead::lead_generation, publish::publish, remix::remix};
use crate::utils::{
    constants::{ACCESS_CONTROLS, AGENTS, LENS_CHAIN_ID, TRIPLEA_URI},
    contracts::{initialize_api, initialize_contracts},
    lens::{handle_lens_account, handle_tokens},
    types::{AgentActivity, AgentManager, Collection, SavedTokens, TripleAAgent, TripleAWorker},
};
use crate::ActivityType;
use chrono::{Timelike, Utc};
use ethers::{
    contract::{self, FunctionCall},
    middleware::{Middleware, SignerMiddleware},
    providers::{Http, Provider},
    signers::LocalWallet,
    types::{Address, Eip1559TransactionRequest, NameOrAddress, H160, H256, U256},
};
use reqwest::Client;
use serde_json::{json, Value};
use std::{error::Error, io, str::FromStr, sync::Arc, time::Duration};
use tokio::time;

impl AgentManager {
    pub fn new(agent: &TripleAAgent) -> Option<Self> {
        let contracts = initialize_contracts(agent.id);
        initialize_api();

        match contracts {
            Some((access_controls_contract, agents_contract)) => Some(AgentManager {
                agent: agent.clone(),
                current_queue: Vec::new(),
                agents_contract,
                access_controls_contract,
                tokens: None,
            }),
            None => {
                eprintln!(
                    "Failed to initialize contracts for agent with ID: {}",
                    agent.id
                );
                None
            }
        }
    }

    pub async fn resolve_activity(&mut self) -> Result<(), Box<dyn Error + Send + Sync>> {
        self.agent.last_active_time = Utc::now().num_seconds_from_midnight();
        if self.current_queue.len() > 0 {
            return Ok(());
        }

        let collections_info = self.get_collections_info().await;

        match collections_info {
            Ok(info) => {
                self.current_queue = info.clone();

                if info.len() < 1 {
                    println!(
                        "No collections for agent this round for agent_{}",
                        self.agent.id
                    );
                    return Ok(());
                }

                match self.pay_rent().await {
                    Ok(_) => {
                        let _ = self.queue_lens_activity().await;
                    }
                    Err(err) => {
                        eprintln!("Error paying rent: {:?}", err);
                    }
                }
            }
            Err(err) => {
                eprintln!("Error obtaining collection information: {:?}", err);
            }
        }

        Ok(())
    }

    async fn get_faucet_grass(&mut self) -> Result<(), Box<dyn Error + Send + Sync>> {
        let method = self.access_controls_contract.method::<_, U256>(
            "getNativeGrassBalance",
            H160::from_str(&self.agent.wallet.clone()).unwrap(),
        );

        match method {
            Ok(call) => {
                let result: Result<
                    U256,
                    contract::ContractError<SignerMiddleware<Arc<Provider<Http>>, LocalWallet>>,
                > = call.call().await;

                match result {
                    Ok(balance) => {
                        println!("Agent Grass Balance: {}\n", balance);
                        if balance <= U256::from(1u128.pow(18)) {
                            let method = self.access_controls_contract.method::<_, H256>(
                                "faucet",
                                (self.agent.wallet.clone(), 2 * 10u128.pow(17)),
                            );

                            match method {
                                Ok(call) => {
                                    let FunctionCall { tx, .. } = call;

                                    if let Some(tx_request) = tx.as_eip1559_ref() {
                                        let gas_price = U256::from(500_000_000_000u64);
                                        let max_priority_fee = U256::from(25_000_000_000u64);
                                        let gas_limit = U256::from(300_000);

                                        let client = self.agents_contract.client().clone();
                                        let chain_id = *LENS_CHAIN_ID;
                                        let req = Eip1559TransactionRequest {
                                            from: Some(
                                                self.agent.wallet.parse::<Address>().unwrap(),
                                            ),
                                            to: Some(NameOrAddress::Address(
                                                ACCESS_CONTROLS.parse::<Address>().unwrap(),
                                            )),
                                            gas: Some(gas_limit),
                                            value: tx_request.value,
                                            data: tx_request.data.clone(),
                                            max_priority_fee_per_gas: Some(max_priority_fee),
                                            max_fee_per_gas: Some(gas_price + max_priority_fee),
                                            chain_id: Some(chain_id.into()),
                                            ..Default::default()
                                        };

                                        let pending_tx = match client
                                            .send_transaction(req, None)
                                            .await
                                        {
                                            Ok(tx) => tx,
                                            Err(e) => {
                                                eprintln!("Error sending the transaction to claim GRASS: {:?}", e);
                                                Err(Box::new(e))?
                                            }
                                        };

                                        let tx_hash = match pending_tx.confirmations(1).await {
                                            Ok(hash) => hash,
                                            Err(e) => {
                                                eprintln!(
                                                    "Error with transaction confirmation from Faucet: {:?}",
                                                    e
                                                );
                                                Err(Box::new(e))?
                                            }
                                        };

                                        println!(
                                            "Faucet GRASS Claimed {} TX Hash: {:?}",
                                            self.agent.id, tx_hash
                                        );

                                        return Ok(());
                                    } else {
                                        self.current_queue = Vec::new();
                                        eprintln!("Error in sending Faucet Transaction");
                                        return Err(Box::new(io::Error::new(
                                            io::ErrorKind::Other,
                                            "Error in sending Faucet Transaction",
                                        )));
                                    }
                                }

                                Err(err) => {
                                    self.current_queue = Vec::new();
                                    eprintln!("Error in method for Faucet claim: {:?}", err);
                                    return Err(Box::new(err));
                                }
                            }
                        } else {
                            return Ok(());
                        }
                    }
                    Err(err) => {
                        eprintln!("Error claiming from faucet: {}", err);
                        return Err(Box::new(err));
                    }
                }
            }
            Err(err) => {
                eprintln!("Error getting agent GRASS balance: {}", err);
                return Err(Box::new(err));
            }
        }
    }

    async fn pay_rent(&mut self) -> Result<(), Box<dyn Error + Send + Sync>> {
        let mut rent_tokens: Vec<H160> = vec![];
        let mut rent_collection_ids: Vec<U256> = vec![];

        let _ = self.get_faucet_grass().await;

        for collection in &self.current_queue {
            for token in &collection.collection.tokens {
                let method = self.agents_contract.method::<_, U256>(
                    "getAgentActiveBalance",
                    (
                        H160::from_str(token).unwrap(),
                        self.agent.id,
                        collection.collection.collection_id,
                    ),
                );

                match method {
                    Ok(call) => {
                        let result: Result<
                            U256,
                            contract::ContractError<
                                SignerMiddleware<Arc<Provider<Http>>, LocalWallet>,
                            >,
                        > = call.call().await;

                        match result {
                            Ok(balance) => {
                                println!("Balance: {}\n", balance);

                                match self.calculate_rent(collection, token).await {
                                    Ok(cycle_rent) => {
                                        if balance >= (cycle_rent) {
                                            rent_tokens.push(H160::from_str(token).unwrap());
                                            rent_collection_ids.push(collection.collection_id);
                                            break;
                                        }
                                    }
                                    Err(err) => {
                                        eprintln!("Error calculating rent: {}", err);
                                    }
                                }
                            }
                            Err(err) => {
                                eprintln!("Error calling token balance: {}", err);
                            }
                        }
                    }
                    Err(err) => {
                        eprintln!("Error getting active token balance: {}", err);
                    }
                }
            }
        }

        println!(
            "Rent: {:?} {:?}\n",
            rent_collection_ids.clone(),
            rent_tokens
        );

        if rent_collection_ids.len() > 0 {
            println!(
                "Method data {:?} {:?} {}",
                rent_tokens,
                rent_collection_ids.clone(),
                self.agent.id
            );
            let method = self
                .agents_contract
                .method::<(Vec<Address>, Vec<U256>, U256), H256>(
                    "payRent",
                    (
                        rent_tokens.clone(),
                        rent_collection_ids.clone(),
                        U256::from(self.agent.id as u64),
                    ),
                );

            match method {
                Ok(call) => {
                    let FunctionCall { tx, .. } = call;

                    if let Some(tx_request) = tx.as_eip1559_ref() {
                        let gas_price = U256::from(500_000_000_000u64);
                        let max_priority_fee = U256::from(25_000_000_000u64);
                        let gas_limit = U256::from(300_000);

                        let client = self.agents_contract.client().clone();
                        let chain_id = *LENS_CHAIN_ID;
                        let req = Eip1559TransactionRequest {
                            from: Some(self.agent.wallet.parse::<Address>().unwrap()),
                            to: Some(NameOrAddress::Address(AGENTS.parse::<Address>().unwrap())),
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
                                eprintln!("Error sending the transaction for payRent: {:?}", e);
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

                        println!("Agent {} TX Hash: {:?}", self.agent.id, tx_hash);

                        self.current_queue
                            .retain(|item| rent_collection_ids.contains(&item.collection_id));

                        println!(
                            "Final queue for agent{}: {:?}",
                            self.agent.id, self.current_queue
                        );

                        Ok(())
                    } else {
                        self.current_queue = Vec::new();
                        eprintln!("Error in sending Transaction");
                        Err(Box::new(io::Error::new(
                            io::ErrorKind::Other,
                            "Error in sending Transaction",
                        )))
                    }
                }

                Err(err) => {
                    self.current_queue = Vec::new();
                    eprintln!("Error in create method for payRent: {:?}", err);
                    Err(Box::new(err))
                }
            }
        } else {
            self.current_queue = Vec::new();
            println!(
                "No collection Ids with sufficient tokens for agent_{}",
                self.agent.id
            );
            Ok(())
        }
    }

    async fn get_collections_info(
        &self,
    ) -> Result<Vec<AgentActivity>, Box<dyn Error + Send + Sync>> {
        let client = Client::new();
        let query = json!({
            "query": r#"
            query ($TripleAAgents_id: Int!) {
                agentCreateds(where: { TripleAAgents_id: $TripleAAgents_id }, first: 1) {
                    balances {
                        collection {
                            artist
                            collectionId
                            metadata {
                                description
                                image
                                title
                            }
                            prices
                            tokens
                        }
                        worker {
                            publish
                            remix
                            lead
                            leadFrequency
                            publishFrequency
                            leadFrequency
                        }
                        collectionId
                        token
                        totalBalance
                        activeBalance
                        instructions
                    }
                }
            }
            "#,
            "variables": {
                "TripleAAgents_id": self.agent.id
            }
        });

        let response = time::timeout(Duration::from_secs(60), async {
            let res = client.post(TRIPLEA_URI).json(&query).send().await?;

            res.json::<Value>().await
        })
        .await;

        match response {
            Ok(result) => match result {
                Ok(result) => {
                    let empty_vec = vec![];
                    let agent_createds = result["data"]["agentCreateds"]
                        .as_array()
                        .unwrap_or(&empty_vec);
                    let mut activities = Vec::new();

                    for agent_created in agent_createds {
                        for balance in agent_created["balances"].as_array().unwrap_or(&vec![]) {
                            let artist = balance["collection"]["artist"]
                                .as_str()
                                .unwrap_or_default()
                                .to_string();

                            let username =
                                handle_lens_account(&artist, true).await.unwrap_or_default();

                            activities.push(AgentActivity {
                                collection: Collection {
                                    collection_id: U256::from_dec_str(
                                        balance["collection"]["collectionId"]
                                            .as_str()
                                            .unwrap_or("0"),
                                    )
                                    .unwrap_or_default(),
                                    artist,
                                    username,
                                    image: balance["collection"]["metadata"]["image"]
                                        .as_str()
                                        .unwrap_or_default()
                                        .to_string(),
                                    title: balance["collection"]["metadata"]["title"]
                                        .as_str()
                                        .unwrap_or_default()
                                        .to_string(),
                                    description: balance["collection"]["metadata"]["description"]
                                        .as_str()
                                        .unwrap_or_default()
                                        .to_string(),
                                    prices: balance["collection"]["prices"]
                                        .as_array()
                                        .unwrap_or(&vec![])
                                        .iter()
                                        .filter_map(|v| {
                                            v.as_str().and_then(|s| U256::from_dec_str(s).ok())
                                        })
                                        .collect(),
                                    tokens: balance["collection"]["tokens"]
                                        .as_array()
                                        .unwrap_or(&vec![])
                                        .iter()
                                        .filter_map(|v| v.as_str().map(|s| s.to_string()))
                                        .collect(),
                                },
                                custom_instructions: balance["instructions"]
                                    .as_str()
                                    .unwrap_or_default()
                                    .to_string(),
                                token: balance["token"].as_str().unwrap_or_default().to_string(),
                                active_balance: U256::from_dec_str(
                                    balance["activeBalance"].as_str().unwrap_or("0"),
                                )
                                .unwrap_or_default(),
                                total_balance: U256::from_dec_str(
                                    balance["totalBalance"].as_str().unwrap_or("0"),
                                )
                                .unwrap_or_default(),
                                collection_id: U256::from_dec_str(
                                    balance["collectionId"].as_str().unwrap_or("0"),
                                )
                                .unwrap_or_default(),
                                worker: TripleAWorker {
                                    lead: balance["worker"]["lead"].as_bool().unwrap_or_default(),
                                    publish: balance["worker"]["publish"]
                                        .as_bool()
                                        .unwrap_or_default(),
                                    remix: balance["worker"]["remix"].as_bool().unwrap_or_default(),
                                    lead_frequency: U256::from_dec_str(
                                        balance["worker"]["leadFrequency"].as_str().unwrap_or("0"),
                                    )
                                    .unwrap_or_default(),

                                    publish_frequency: U256::from_dec_str(
                                        balance["worker"]["publishFrequency"]
                                            .as_str()
                                            .unwrap_or("0"),
                                    )
                                    .unwrap_or_default(),
                                    remix_frequency: U256::from_dec_str(
                                        balance["worker"]["remixFrequency"].as_str().unwrap_or("0"),
                                    )
                                    .unwrap_or_default(),
                                },
                            });
                        }
                    }

                    Ok(activities)
                }
                Err(err) => {
                    eprintln!("Error in response: {:?}", err);
                    Err(Box::new(err))
                }
            },
            Err(err) => {
                eprintln!("Time out: {:?}", err);
                Err(Box::new(io::Error::new(
                    io::ErrorKind::TimedOut,
                    format!("Timeout: {:?}", err),
                )))
            }
        }
    }

    async fn queue_lens_activity(&mut self) -> Result<(), Box<dyn Error + Send + Sync>> {
        let current_time = Utc::now().num_seconds_from_midnight() as i64;
        let remaining_time = self.agent.clock as i64 - current_time;

        let adjusted_remaining_time = if remaining_time > 0 {
            remaining_time
        } else {
            7200
        };

        let queue = self.current_queue.clone();
        let queue_size = queue.len() as i64;

        let interval = if queue_size > 0 {
            adjusted_remaining_time / queue_size
        } else {
            0
        };

        println!(
            "Queue Length for Agent_{} before loop: {}",
            self.agent.id,
            self.current_queue.len()
        );

        for activity in queue {
            let tokens = handle_tokens(
                self.agent.id,
                &self.agent.account_address,
                self.tokens.clone(),
            )
            .await;

            match tokens {
                Ok(new_tokens) => {
                    self.tokens = Some(new_tokens);
                    self.current_queue
                        .retain(|item| item.collection_id == activity.collection_id);

                    let agent = self.agent.clone();
                    let tokens = self.tokens.clone();
                    tokio::spawn(async move {
                        cycle_activity(&agent, tokens, &activity, interval).await;
                    });
                }

                Err(err) => {
                    eprintln!("Error renewing Lens tokens: {:?}", err);
                }
            }

            tokio::time::sleep(std::time::Duration::from_secs(interval as u64)).await;
        }

        println!(
            "Queue Length for Agent_{} after finishing: {}",
            self.agent.id,
            self.current_queue.len()
        );

        Ok(())
    }

    async fn calculate_rent(
        &self,
        activity: &AgentActivity,
        token: &String,
    ) -> Result<U256, Box<dyn Error + Send + Sync>> {
        let mut rent_total = U256::from(0);

        if activity.worker.lead {
            let rent_method = self
                .access_controls_contract
                .method::<_, U256>("getTokenCycleRentLead", H160::from_str(token).unwrap());

            match rent_method {
                Ok(rent_call) => {
                    let token_result: Result<
                        U256,
                        contract::ContractError<SignerMiddleware<Arc<Provider<Http>>, LocalWallet>>,
                    > = rent_call.call().await;

                    match token_result {
                        Ok(rent_threshold) => {
                            rent_total += rent_threshold * activity.worker.lead_frequency;
                        }
                        Err(err) => {
                            eprintln!("Error in rent method lead: {}", err);
                        }
                    }
                }
                Err(err) => {
                    eprintln!("Error in rent method lead: {}", err);
                }
            }
        }

        if activity.worker.publish {
            let rent_method = self
                .access_controls_contract
                .method::<_, U256>("getTokenCycleRentPublish", H160::from_str(token).unwrap());

            match rent_method {
                Ok(rent_call) => {
                    let token_result: Result<
                        U256,
                        contract::ContractError<SignerMiddleware<Arc<Provider<Http>>, LocalWallet>>,
                    > = rent_call.call().await;

                    match token_result {
                        Ok(rent_threshold) => {
                            rent_total += rent_threshold * activity.worker.publish_frequency;
                        }
                        Err(err) => {
                            eprintln!("Error in rent method publish: {}", err);
                        }
                    }
                }
                Err(err) => {
                    eprintln!("Error in rent method publish: {}", err);
                }
            }
        }

        if activity.worker.remix {
            let rent_method = self
                .access_controls_contract
                .method::<_, U256>("getTokenCycleRentRemix", H160::from_str(token).unwrap());

            match rent_method {
                Ok(rent_call) => {
                    let token_result: Result<
                        U256,
                        contract::ContractError<SignerMiddleware<Arc<Provider<Http>>, LocalWallet>>,
                    > = rent_call.call().await;

                    match token_result {
                        Ok(rent_threshold) => {
                            rent_total += rent_threshold * activity.worker.remix_frequency;
                        }
                        Err(err) => {
                            eprintln!("Error in rent method remix: {}", err);
                        }
                    }
                }
                Err(err) => {
                    eprintln!("Error in rent method remix: {}", err);
                }
            }
        }

        Ok(rent_total)
    }
}

async fn cycle_activity(
    agent: &TripleAAgent,
    tokens: Option<SavedTokens>,
    activity: &AgentActivity,
    interval: i64,
) {
    let total_activities = activity.worker.lead_frequency.as_u64()
        + activity.worker.publish_frequency.as_u64()
        + activity.worker.remix_frequency.as_u64();
    let activity_interval = interval / total_activities as i64;

    let mut tasks = vec![];
    for _ in 0..activity.worker.lead_frequency.as_u64() {
        tasks.push(ActivityType::Lead);
    }
    for _ in 0..activity.worker.publish_frequency.as_u64() {
        tasks.push(ActivityType::Publish);
    }
    for _ in 0..activity.worker.remix_frequency.as_u64() {
        tasks.push(ActivityType::Remix);
    }

    tasks = distribute_tasks(tasks);

    let handles: Vec<_> = tasks
        .into_iter()
        .enumerate()
        .map(|(i, task)| {
            let agent = agent.clone();
            let tokens = tokens.clone();
            let collection = activity.collection.clone();
            let instructions = activity.custom_instructions.clone();

            tokio::spawn(async move {
                tokio::time::sleep(std::time::Duration::from_secs(
                    (i as i64 * activity_interval) as u64,
                ))
                .await;

                match task {
                    ActivityType::Lead => {
                        let _ = lead_generation(&agent, &collection, tokens, &instructions).await;
                    }
                    ActivityType::Publish => {
                        let _ = publish(&agent, tokens, &collection, &instructions).await;
                    }
                    ActivityType::Remix => {
                        let _ = remix().await;
                    }
                }
            })
        })
        .collect();

    for handle in handles {
        let _ = handle.await;
    }

    println!(
        "Finished cycle_activity for Agent_{} and Activity {:?}",
        agent.id, activity
    );
}

fn distribute_tasks(mut tasks: Vec<ActivityType>) -> Vec<ActivityType> {
    let mut distributed = vec![];
    while !tasks.is_empty() {
        if let Some(task) = tasks.pop() {
            distributed.push(task);
        }
        tasks.rotate_left(1);
    }
    distributed
}
