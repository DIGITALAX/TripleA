use base64::{engine::general_purpose::STANDARD, Engine as _};
use dotenv::{dotenv, from_filename, var};
use reqwest::{
    multipart::{Form, Part},
    Client,
};
use serde_json::{from_str, Value};
use std::{
    error::Error,
    sync::{Arc, Once},
};

use crate::IPFSResponse;

static INIT: Once = Once::new();
static mut CLIENT: Option<Arc<Client>> = None;

pub fn create_client() -> Arc<Client> {
    unsafe {
        INIT.call_once(|| {
            dotenv().ok();
            let client = Client::new();
            CLIENT = Some(Arc::new(client));
        });
        CLIENT.clone().expect("Client not initialized")
    }
}

pub fn authentication() -> String {
    dotenv().ok();
    from_filename(".env").ok();
    let id = var("INFURA_PROJECT_ID").expect("INFURA_PROJECT_ID isn't configured");
    let key = var("INFURA_PROJECT_SECRET").expect("INFURA_PROJECT_SECRET isn't configured");
    let aut = format!("{}:{}", id, key);
    STANDARD.encode(aut)
}

pub async fn upload_ipfs(data: String) -> Result<IPFSResponse, Box<dyn Error + Send + Sync>> {
    let client = create_client();
    let aut_encoded = authentication();

    let form: Form = Form::new().part("file", Part::text(data.clone()).file_name("data.json"));

    let response = client
        .post("https://ipfs.infura.io:5001/api/v0/add")
        .header("Authorization", format!("Basic {}", aut_encoded))
        .multipart(form)
        .send()
        .await?;

    let text_response = response.text().await?;
    let ipfs_response: IPFSResponse = from_str(&text_response)?;

    Ok(ipfs_response)
}

pub async fn get_storage_key() -> Result<String, Box<dyn Error>> {
    let client = Client::new();

    let response = client
        .post("https://storage-api.testnet.lens.dev/link/new")
        .send()
        .await?;

    if !response.status().is_success() {
        let error_text = response.text().await?;
        return Err(format!("Error obtaining storage_key: {}", error_text).into());
    }

    let text_response = response.text().await?;
    let json_response: Value = from_str(&text_response)?;

    if let Some(storage_key) = json_response.get(0).and_then(|item| item.get("storage_key")) {
        if let Some(storage_key_str) = storage_key.as_str() {
            return Ok(storage_key_str.to_string());
        }
    }

    Err("Couldn't obtain storage_key.".into())
}

pub async fn upload_lens_storage(data: String) -> Result<String, Box<dyn Error>> {
    let client = create_client();
    let storage_key = get_storage_key().await?;
    let url = format!("https://storage-api.testnet.lens.dev/{}", storage_key);

    let response = client
        .post(url)
        .header("Content-Type", "application/json")
        .body(data)
        .send()
        .await?;

    if !response.status().is_success() {
        let error_text = response.text().await?;
        return Err(format!("Error uploading to Lens Storage: {}", error_text).into());
    }

    let text_response = response.text().await?;
    let json_response: Value = from_str(&text_response)?;

    if let Some(uri) = json_response.get(0).and_then(|item| item.get("uri")) {
        if let Some(uri_str) = uri.as_str() {
            return Ok(uri_str.to_string());
        }
    }

    Err("Couldn't get URI.".into())
}
