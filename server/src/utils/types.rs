use ethers::{
    contract::ContractInstance,
    core::k256::ecdsa::SigningKey,
    middleware::SignerMiddleware,
    providers::{Http, Provider},
    signers::Wallet,
    types::U256,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TripleAAgent {
    pub id: u32,
    pub name: String,
    pub description: String,
    pub cover: String,
    pub custom_instructions: String,
    pub wallet: String,
    pub clock: u32,
    pub last_active_time: u32,
    pub account_address: String,
}

#[derive(Debug, Clone, Deserialize, Serialize, PartialEq)]
pub struct TripleAWorker {
    pub lead: bool,
    pub publish: bool,
    pub remix: bool,
    pub lead_frequency: U256,
    pub publish_frequency: U256,
    pub remix_frequency: U256,
}

#[derive(Debug, Clone)]
pub struct AgentManager {
    pub agent: TripleAAgent,
    pub current_queue: Vec<AgentActivity>,
    pub agents_contract: Arc<
        ContractInstance<
            Arc<SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>>,
            SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>,
        >,
    >,
    pub access_controls_contract: Arc<
        ContractInstance<
            Arc<SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>>,
            SignerMiddleware<Arc<Provider<Http>>, Wallet<SigningKey>>,
        >,
    >,
    pub tokens: Option<SavedTokens>,
}

#[derive(Debug, Clone, Deserialize, Serialize, PartialEq)]
pub struct Collection {
    pub image: String,
    pub title: String,
    pub description: String,
    pub artist: String,
    pub username: String,
    pub collection_id: U256,
    pub prices: Vec<U256>,
    pub tokens: Vec<String>,
}

#[derive(Debug, Clone, Deserialize, Serialize, PartialEq)]
pub struct AgentActivity {
    pub collection: Collection,
    pub token: String,
    pub worker: TripleAWorker,
    pub active_balance: U256,
    pub total_balance: U256,
    pub collection_id: U256,
    pub custom_instructions: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct IPFSResponse {
    Name: String,
    pub Hash: String,
    Size: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LensTokens {
    pub access_token: String,
    pub refresh_token: String,
    pub id_token: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Publication {
    #[serde(rename = "$schema")]
    pub schema: String,
    pub lens: Content,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct Image {
    #[serde(rename = "type")]
    pub tipo: String,
    pub item: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Content {
    pub mainContentFocus: String,
    pub title: String,
    pub content: String,
    pub id: String,
    pub locale: String,
    pub tags: Vec<String>,
    pub image: Image,
}

#[derive(Debug, Clone)]
pub struct SavedTokens {
    pub tokens: LensTokens,
    pub expiry: i64,
}
#[derive(Debug, Clone)]
pub enum ActivityType {
    Publish,
    Lead,
    Remix
}