use crate::utils::{types::Collection, constants::{VENICE_API, MODELS, SAMPLE_PROMPT}};
use ethers::types::U256;
use rand::{thread_rng, Rng};
use dotenv::{from_filename, var};
use regex::Regex;
use reqwest::Client;
use serde_json::{json, Value};
use std::{ error::Error, io};

pub async fn call_chat_completion(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    agent_id: &u32, model: &str
) -> Result<String, Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    from_filename(".env").ok();
    let venice_key: String =
        var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
    let max_completion_tokens = [100, 300, 600][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("In no more than {} tokens, create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}",
    max_completion_tokens, collection.description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

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
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    });

    let response = client
    .post(format!("{}chat/completions", VENICE_API))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", venice_key))
    .json(&request_body)
    .send()
    .await;

    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Venice call successful for agent_{}: {}",  agent_id, completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }
}


pub async fn receive_query(description: &str, title: &str, model: &str)  -> Result<String, Box<dyn Error + Send + Sync>>  {
    from_filename(".env").ok();
    let venice_key: String =
        var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
    let max_completion_tokens = 300;
    let input_prompt = 
    format!("In 100 words or less take the combined description and title below to create a query that can be used to search for similar content, for example a word or pair of words that you would put in a pinterest search bar to search for similar content: \n\nDescription: {}\n\nTitle: {}", description, title);
 
    let mut messages = vec![];

    messages.push(json!({
        "role": "user",
        "content":input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    });

    let response = client
        .post(format!("{}chat/completions", VENICE_API))
        .header("Content-Type", "application/json")
        .header("Authorization", format!("Bearer {}", venice_key))
        .json(&request_body)
        .send()
        .await;

    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();

 
        println!("Venice call successful for receiving query: {}",  completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }

    
}


pub async fn call_comment_completion(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str, model: &str)  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {
        from_filename(".env").ok();
        let venice_key: String =
            var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
        let max_completion_tokens = [100, 300, 600][thread_rng().gen_range(0..3)];
        let input_prompt = 
        format!("In no more than {} tokens, write a comment that is going to respond to this content: {}.\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
        ,max_completion_tokens, post_content, collection_description);
       
        let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

 
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
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens
    });

    let response = client
    .post(format!("{}chat/completions", VENICE_API))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", venice_key))
    .json(&request_body)
    .send()
    .await;
    
    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
        println!("Venice call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }

    
}

pub async fn call_quote_completion(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str,  model: &str
    )  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {
        from_filename(".env").ok();
        let venice_key: String =
            var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
        let max_completion_tokens = [200, 400, 700][thread_rng().gen_range(0..3)];
        let input_prompt = 
        format!("In no more than {} tokens, write a comment that is going to respond to this content: {}.\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
        , max_completion_tokens, post_content, collection_description);
       
       
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

 
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
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    });

    let response = client
    .post(format!("{}chat/completions", VENICE_API))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", venice_key))
    .json(&request_body)
    .send()
    .await;
    
    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
 
        println!("Venice call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }

    
}


pub async fn call_feed_completion(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    description: &str, title: &str, model: &str) -> Result<String, Box<dyn Error + Send + Sync>> {
        from_filename(".env").ok();
        let venice_key: String =
            var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!(    "In no more than {} tokens, create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}\n\nMake sure that it fits with the theme of the feed named {} that is about {}"
    , max_completion_tokens, collection.description, title, description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

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
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    });

    let response = client
    .post(format!("{}chat/completions", VENICE_API))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", venice_key))
    .json(&request_body)
    .send()
    .await;

    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();

 
        println!("Venice call successful: {}", completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }
}

pub async fn call_prompt(
    description: &str,
    model: &str
) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let venice_key: String =
        var("VENICE_KEY").expect("VENICE_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("In no more than {} tokens, for the description given I want you to write a prompt that will be used in Stable diffusion to make a remix, the remix will be quite different, just inspired by the description and original image: {}\n\nYou need to format your answer like this with a new line for each item:\n\nImage Prompt: Put the image prompt here to be used.\n\nModel: And here choose between one model in {:?} and put the chosen model here to use to make the image.\n\nHere is an example prompt to guide you of what your prompt format and style should be: {}"
    , max_completion_tokens, description, MODELS, SAMPLE_PROMPT);
   
    let mut messages = vec![];


    messages.push(json!({
        "role": "user",
        "content":input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": model,
        "messages": messages,
        "max_completion_tokens": max_completion_tokens,
    });

    let response = client
    .post(format!("{}chat/completions", VENICE_API))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", venice_key))
    .json(&request_body)
    .send()
    .await;

    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Venice call successful for image prompt: {}", completion);
        Ok(extract_values_prompt(&completion)?)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }
}

fn extract_values_prompt(input: &str) -> Result<(String, String), Box<dyn Error + Send + Sync>> {

    let image_prompt_re = Regex::new(r"(?m)^Image Prompt:\s*(.+)")?;
    let model_re = Regex::new(r"(?m)^Model:\s*(\d+)")?;

    let image_prompt = image_prompt_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();
    let model = model_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();
   

    Ok((image_prompt, model))
}

fn extract_values_image(input: &str) -> Result<(String, String, U256, Vec<U256>), Box<dyn Error + Send + Sync>> {
    let title_re = Regex::new(r"(?m)^Title:\s*(.+)")?;
    let description_re = Regex::new(r"(?m)^Description:\s*(.+)")?;
    let amount_re = Regex::new(r"(?m)^Amount:\s*(\d+)")?;
    let mona_re = Regex::new(r"(?m)^Mona:\s*(\d+)")?;
    let grass_re = Regex::new(r"(?m)^Grass:\s*(\d+)")?;
    let bonsai_re = Regex::new(r"(?m)^Bonsai:\s*(\d+)")?;

    let title = title_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();
    let description = description_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();
    let amount: u32 = amount_re.captures(input)
    .and_then(|cap| cap.get(1))
    .and_then(|m| m.as_str().parse::<u32>().ok())
    .unwrap_or_default();

let mona: u64 = mona_re.captures(input)
    .and_then(|cap| cap.get(1))
    .and_then(|m| m.as_str().parse::<u64>().ok())
    .unwrap_or_default();

let grass: u64 = grass_re.captures(input)
    .and_then(|cap| cap.get(1))
    .and_then(|m| m.as_str().parse::<u64>().ok())
    .unwrap_or_default();

let bonsai: u64 = bonsai_re.captures(input)
    .and_then(|cap| cap.get(1))
    .and_then(|m| m.as_str().parse::<u64>().ok())
    .unwrap_or_default();


    Ok((title, description, U256::from(amount), vec![U256::from(mona), U256::from(grass), U256::from(bonsai)]))
}



fn extract_values_drop(input: &str) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    let title_re = Regex::new(r"(?m)^Title:\s*(.+)")?;
    let description_re = Regex::new(r"(?m)^Description:\s*(.+)")?;

    let title = title_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();
    let description = description_re.captures(input).and_then(|cap| cap.get(1).map(|m| m.as_str())).unwrap_or_default().to_string();


    Ok((title, description))
}


pub async fn call_image_details(
) -> Result<(String, String, U256, Vec<U256>), Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("For a new NFT to be minted, you need to create a title, description, state the amount that needs to be minted and its price according to three different tokens.\n\nYou need to format your answer like this with a new line for each item:\n\nTitle: Put the title here of the creation.\n\nDescription: Put the description here of the creation.\n\nAmount: Put the amount of the item to be minted, it must be between 3 and 30.\n\nMona: Put in eth wei the price of the collection in MONA tokens where 1 MONA is worth around $70 USD. The price can't be above $200.\n\nGRASS: Put in eth wei the price of the collection in GRASS tokens where 1 GRASS is worth around $70 USD. The price can't be above $200.\n\nBonsai: Put in eth wei the price of the collection in BONSAI tokens where 1 BONSAI is worth around $70 USD. The price can't be above $200.");
   
    let mut messages = vec![];


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
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Venice call successful for image prompt: {}", completion);
        Ok(extract_values_image(&completion)?)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }
}

pub async fn call_drop_details(
    description: &str
) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("Give me a title and description for a drop that is slightly inspired by this description, but is also totally different: {}\n\nYou need to format your answer like this with a new line for each item:\n\nTitle: Put the title here of the creation.\n\nDescription: Put the description here of the creation."
    , description);
   
    let mut messages = vec![];


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
            eprintln!("Error sending request to Venice API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Venice call successful for drop prompt: {}", completion);
        Ok(extract_values_drop(&completion)?)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Venice prompt {:?}", response.status()),
        )));
    }
}
