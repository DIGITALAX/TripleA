use crate::Collection;

use rand::{thread_rng, Rng};
use dotenv::{from_filename, var};
use reqwest::Client;
use serde_json::{json, Value};
use std::{ error::Error, io};

pub async fn call_chat_completion(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    agent_id: &u32
) -> Result<String, Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!(    "Create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}"
    , collection.description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not user quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

    let mut messages = vec![];

    messages.push(json!({
        "role": "system",
        "content": combined_instructions
    }));
    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "gpt-4o-mini",
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
        "n": 1,
    });

    let response = client
        .post("https://api.openai.com/v1/chat/completions")
        .header("Authorization", format!("Bearer {}", open_ai_key))
        .json(&request_body)
        .send()
        .await;

    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to OpenAI API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();

 
        println!("Open AI call successful for agent_{}: {}",  agent_id, completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining open AI prompt {:?}", response.status()),
        )));
    }
}
