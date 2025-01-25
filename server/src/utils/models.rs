use crate::Collection;

use rand::{thread_rng, Rng};
use dotenv::{from_filename, var};
use reqwest::Client;
use serde_json::{json, Value};
use std::{ error::Error, io};

pub async fn call_chat_completion_openai(
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

 
        println!("OpenAI call successful for agent_{}: {}",  agent_id, completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining OpenAI prompt {:?}", response.status()),
        )));
    }
}



pub async fn call_chat_completion_claude(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    agent_id: &u32
) -> Result<String, Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let anthropic_api_key: String = 
    var("ANTHROPIC_API_KEY").expect("ANTHROPIC_API_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!(    "Create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}"
    , collection.description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

    let mut messages = vec![];

    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "claude-3-5-sonnet-20241022",
        "messages": messages,
        "system": combined_instructions,
        "max_tokens": max_completion_tokens,
    });


    let response = client
    .post("https://api.anthropic.com/v1/messages")
    .header("x-api-key", anthropic_api_key)
    .header("anthropic-version", "2023-06-01")
    .header("content-type", "application/json")
    .json(&request_body)
    .send()
    .await;


    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Claude API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["content"][0]["text"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Claude call successful for agent_{}: {}",  agent_id, completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Claude prompt {:?}", response.status()),
        )));
    }
}




pub async fn receive_query_openai(description: &str, title: &str, image: &str)  -> Result<String, Box<dyn Error + Send + Sync>>  {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
    let max_completion_tokens = 100;
    let input_prompt = 
    format!("In 100 tokens or less take the combined description, title and image below to create a query that can be used to search for similar content, for example a word or pair of words that you would put in a pinterest search bar to search for similar content: \n\nDescription: {}\n\nTitle: {}\n\nImage: {}"
    , description, title, image);
 
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

 
        println!("OpenAI call successful for receiving query: {}",  completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining OpenAI prompt {:?}", response.status()),
        )));
    }

    
}


pub async fn receive_query_claude(description: &str, title: &str, image: &str)  -> Result<String, Box<dyn Error + Send + Sync>>  {

    from_filename(".env").ok();
    let anthropic_api_key: String = 
    var("ANTHROPIC_API_KEY").expect("ANTHROPIC_API_KEY not configured in .env");
    let max_completion_tokens = 100;
    let input_prompt = 
    format!("In 100 tokens or less take the combined description, title and image below to create a query that can be used to search for similar content, for example a word or pair of words that you would put in a pinterest search bar to search for similar content: \n\nDescription: {}\n\nTitle: {}\n\nImage: {}"
    , description, title, image);
   
    let mut messages = vec![];

    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "claude-3-5-sonnet-20241022",
        "messages": messages,
        "max_tokens": max_completion_tokens,
    });


    let response = client
    .post("https://api.anthropic.com/v1/messages")
    .header("x-api-key", anthropic_api_key)
    .header("anthropic-version", "2023-06-01")
    .header("content-type", "application/json")
    .json(&request_body)
    .send()
    .await;


    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Claude API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["content"][0]["text"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Claude call successful for receiving query: {}",  completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Claude prompt {:?}", response.status()),
        )));
    }
    
}

pub async fn call_comment_completion_claude(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str,   attachment_type: &str,
    item: &str,
    extra1: &str,
    extra2: &str,)  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {

    from_filename(".env").ok();
    let anthropic_api_key: String = 
    var("ANTHROPIC_API_KEY").expect("ANTHROPIC_API_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("Write a comment that is going to respond to this content: {}.\nThe post also might have an attachment: {}, {}, {}, {}\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
    , post_content, attachment_type, item, extra1, extra2, collection_description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);


    let mut messages = vec![];

    
    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "claude-3-5-sonnet-20241022",
        "messages": messages,
        "system": combined_instructions,
        "max_tokens": max_completion_tokens,
    });


    let response = client
    .post("https://api.anthropic.com/v1/messages")
    .header("x-api-key", anthropic_api_key)
    .header("anthropic-version", "2023-06-01")
    .header("content-type", "application/json")
    .json(&request_body)
    .send()
    .await;


    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Claude API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["content"][0]["text"]
        .as_str()
        .unwrap_or("")
        .to_string();
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
        println!("Claude call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Claude prompt {:?}", response.status()),
        )));
    }
    
}


pub async fn call_comment_completion_openai(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str,     attachment_type: &str,
    item: &str,
    extra1: &str,
    extra2: &str,)  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
        let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
        let input_prompt = 
        format!("Write a comment that is going to respond to this content: {}.\nThe post also might have an attachment: {}, {}, {}, {}\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
        , post_content, attachment_type, item, extra1, extra2, collection_description);
       
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
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
        println!("OpenAI call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining OpenAI prompt {:?}", response.status()),
        )));
    }

    
}


pub async fn call_quote_completion_claude(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str,    attachment_type: &str,
    item: &str,
    extra1: &str,
    extra2: &str,)  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {

    from_filename(".env").ok();
    let anthropic_api_key: String = 
    var("ANTHROPIC_API_KEY").expect("ANTHROPIC_API_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!("Write a response to this content: {}.\nThe post also might have an attachment: {}, {}, {}, {}\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
    , post_content, attachment_type, item, extra1, extra2, collection_description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

   
    let mut messages = vec![];

    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "claude-3-5-sonnet-20241022",
        "messages": messages,
        "system": combined_instructions,

        "max_tokens": max_completion_tokens,
    });


    let response = client
    .post("https://api.anthropic.com/v1/messages")
    .header("x-api-key", anthropic_api_key)
    .header("anthropic-version", "2023-06-01")
    .header("content-type", "application/json")
    .json(&request_body)
    .send()
    .await;


    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Claude API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["content"][0]["text"]
        .as_str()
        .unwrap_or("")
        .to_string();
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
        println!("Claude call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Claude prompt {:?}", response.status()),
        )));
    }
    
}


pub async fn call_quote_completion_openai(post_content: &str, custom_instructions: &str, collection_instructions: &str, collection_description: &str,     attachment_type: &str,
    item: &str,
    extra1: &str,
    extra2: &str,)  -> Result<(String, bool), Box<dyn Error + Send + Sync>>  {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
        let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
        let input_prompt = 
        format!("Write a response to this content: {}.\nThe post also might have an attachment: {}, {}, {}, {}\n\n But make sure to also take into account this collection information:\nDescription: {}.\n\nYour response shouldn't be obvious in including the collection information, but the goal is to potentially invite this person to be curious about finding more information about the artist and collection, in a non pushy / forceful / obvious way. Maybe it doesn't make sense to include the collection information, it's your choice. At the very very end of the message in a new line you need to also decide whether this comment should include the image of the collection or not, if not then put this and only this in a new line at the end of the message: use_image: YES, otherwise put use_image: NO."
        , post_content, attachment_type, item, extra1, extra2, collection_description);
       
       
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
    let use_image = completion.contains("use_image: YES");
    let completion = completion.split("use_image: ").next().unwrap_or("").trim().to_string();
 
 
        println!("OpenAI call successful for receiving query: {}",  completion);
        Ok((completion, use_image))
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining OpenAI prompt {:?}", response.status()),
        )));
    }

    
}


pub async fn call_feed_completion_openai(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    description: &str, title: &str) -> Result<String, Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let open_ai_key: String =
        var("OPEN_AI_SECRET").expect("OPEN_AI_SECRET not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!(    "Create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}\n\nMake sure that it fits with the theme of the feed named {} that is about {}"
    , collection.description, title, description);
   
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

 
        println!("OpenAI call successful: {}", completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining OpenAI prompt {:?}", response.status()),
        )));
    }
}


pub async fn call_feed_completion_claude(
    collection: &Collection,
    custom_instructions: &str,
    collection_instructions: &str,
    description: &str, title: &str
) -> Result<String, Box<dyn Error + Send + Sync>> {
    from_filename(".env").ok();
    let anthropic_api_key: String = 
    var("ANTHROPIC_API_KEY").expect("ANTHROPIC_API_KEY not configured in .env");
    let max_completion_tokens = [100, 200, 350][thread_rng().gen_range(0..3)];
    let input_prompt = 
    format!(    "Create a meta response or insightful comment suitable for publication online that highlights this collection and its description: {}\n\nMake sure that it fits with the theme of the feed named {} that is about {}"
    , collection.description, title, description);
   
    let combined_instructions = format!("{}\n\nIn addition, incorporate these specific instructions tailored to this collection: {}\n\nDo not use quotation marks or any special characters in your response, you can use emojis. Don't reply with anything but the publication so it can be posted directly without extra editing.", custom_instructions, collection_instructions);

    let mut messages = vec![];

    messages.push(json!({
        "role": "user",
        "content": input_prompt
    }));

    let client = Client::new();
    let  request_body = json!({
        "model": "claude-3-5-sonnet-20241022",
        "messages": messages,
        "system": combined_instructions,
        "max_tokens": max_completion_tokens,
    });


    let response = client
    .post("https://api.anthropic.com/v1/messages")
    .header("x-api-key", anthropic_api_key)
    .header("anthropic-version", "2023-06-01")
    .header("content-type", "application/json")
    .json(&request_body)
    .send()
    .await;


    let response = match response {
        Ok(resp) => resp,
        Err(e) => {
            eprintln!("Error sending request to Claude API: {}", e);
            return Err(e.into());
        }
    };
    if response.status() == 200 {
    let response_json: Value = response.json().await?;
    let completion = response_json["content"][0]["text"]
        .as_str()
        .unwrap_or("")
        .to_string();
 
        println!("Claude call successful: {}",  completion);
        Ok(completion)
    } else {
        return Err(Box::new(io::Error::new(
            io::ErrorKind::Other,
            format!("Error in obtaining Claude prompt {:?}", response.status()),
        )));
    }
}

