use crate::utils::{
    constants::INFURA_GATEWAY,
    ipfs::upload_lens_storage,
    lens::{feed_info, follow_profiles, make_comment, make_publication, make_quote, search_posts},
    models::{
        call_comment_completion_claude, call_comment_completion_openai,
        call_feed_completion_claude, call_feed_completion_openai, call_quote_completion_claude,
        call_quote_completion_openai, receive_query_claude, receive_query_openai,
    },
    types::{Collection, Content, Image, Publication, SavedTokens, TripleAAgent},
};
use base64::{engine::general_purpose, Engine as _};
use futures::future::join_all;
use serde_json::{to_string, Value};
use std::{error::Error, io};
use uuid::Uuid;

pub async fn lead_generation(
    agent: &TripleAAgent,
    collection: &Collection,
    tokens: Option<SavedTokens>,
    collection_instructions: &str,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match if agent.model == "Claude" {
        receive_query_claude(
            &collection.description,
            &collection.title,
            &collection.image,
        )
        .await
    } else {
        receive_query_openai(
            &collection.description,
            &collection.title,
            &collection.image,
        )
        .await
    } {
        Ok(query) => match search_posts(&agent.wallet, &query).await {
            Ok((posts, profiles)) => {
                let _ = follow_profiles(
                    profiles.clone(),
                    &tokens.as_ref().unwrap().tokens.access_token,
                )
                .await;

                let (comments_posts, quotes_posts) = posts.split_at(posts.len() / 2);

                let _ = make_comments(
                    comments_posts.to_vec(),
                    &tokens.as_ref().unwrap().tokens.access_token,
                    agent.id,
                    &agent.model,
                    &agent.custom_instructions,
                    &collection_instructions,
                    &collection,
                )
                .await;

                let _ = make_quotes(
                    quotes_posts.to_vec(),
                    &tokens.as_ref().unwrap().tokens.access_token,
                    agent.id,
                    &agent.model,
                    &agent.custom_instructions,
                    &collection_instructions,
                    &collection,
                )
                .await;

                let _ = feed_posts(
                    collection,
                    &tokens.as_ref().unwrap().tokens.access_token,
                    agent.id,
                    agent.feeds.clone(),
                    &agent.model,
                    &agent.custom_instructions,
                    &collection_instructions,
                )
                .await;

                Ok(())
            }
            Err(err) => {
                println!("Error finding posts {:?}", err);
                Err(Box::new(io::Error::new(
                    io::ErrorKind::Other,
                    "Error finding posts",
                )))
            }
        },
        Err(err) => {
            println!("Error receiving query {:?}", err);
            Err(Box::new(io::Error::new(
                io::ErrorKind::Other,
                "Error receiving query",
            )))
        }
    }
}

async fn make_comments(
    posts: Vec<Value>,
    auth_tokens: &str,
    private_key: u32,
    model: &str,
    custom_instructions: &str,
    collection_instructions: &str,
    collection: &Collection,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let comment_futures = posts.into_iter().map(|post| async move {
        let mut content = String::new();
        let mut attachment_type = String::new();
        let mut item = String::new();

        if let Some(metadata) = post["metadata"].as_object() {
            content = metadata
                .get("content")
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            if let Some(attachments) = metadata.get("attachments").and_then(|a| a.as_array()) {
                if let Some(attachment) = attachments.first() {
                    match attachment.get("__typename").and_then(|t| t.as_str()) {
                        Some("MediaImage") => {
                            attachment_type = "MediaImage".to_string();
                            item = attachment
                                .get("item")
                                .and_then(|v| v.as_str())
                                .unwrap_or_default()
                                .to_string();

                            item = if item.starts_with("ipfs://") {
                                let hash = item.trim_start_matches("ipfs://");
                                format!("{}/ipfs/{}", INFURA_GATEWAY, hash)
                            } else {
                                item.to_string()
                            };

                            let response = reqwest::get(&item).await?;
                            let image_bytes = response.bytes().await?;
                            item = general_purpose::STANDARD.encode(&image_bytes)
                        }

                        _ => {
                            attachment_type = "Unknown".to_string();
                        }
                    }
                }
            }
        }

        match if model == "Claude" {
            call_comment_completion_claude(
                &content,
                custom_instructions,
                collection_instructions,
                &collection.description,
                &attachment_type,
                &item,
            )
            .await
        } else {
            call_comment_completion_openai(
                &content,
                custom_instructions,
                collection_instructions,
                &collection.description,
                &attachment_type,
                &item,
            )
            .await
        } {
            Ok((llm_response, image)) => {
                match format_response(&llm_response, &collection, image).await {
                    Ok(content) => {
                        let _ = make_comment(
                            &content,
                            private_key,
                            auth_tokens,
                            post["id"].as_str().unwrap_or_default(),
                        )
                        .await;
                    }
                    Err(err) => {
                        println!("Error with Comment format {:?}", err);
                    }
                }
            }
            Err(err) => {
                println!("Error with LLM Comment {:?}", err);
            }
        }
        Ok::<(), Box<dyn Error + Send + Sync>>(())
    });

    let results: Vec<_> = join_all(comment_futures).await;

    for result in results {
        if let Err(e) = result {
            println!("Error with commenting: {:?}", e);
        }
    }

    Ok(())
}

async fn make_quotes(
    posts: Vec<Value>,
    auth_tokens: &str,
    private_key: u32,
    model: &str,
    custom_instructions: &str,
    collection_instructions: &str,
    collection: &Collection,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let quote_futures = posts.into_iter().map(|post| async move {
        let mut content = String::new();
        let mut attachment_type = String::new();
        let mut item = String::new();

        if let Some(metadata) = post["metadata"].as_object() {
            content = metadata
                .get("content")
                .and_then(|v| v.as_str())
                .unwrap_or_default()
                .to_string();

            if let Some(attachments) = metadata.get("attachments").and_then(|a| a.as_array()) {
                if let Some(attachment) = attachments.first() {
                    match attachment.get("__typename").and_then(|t| t.as_str()) {
                        Some("MediaImage") => {
                            attachment_type = "MediaImage".to_string();
                            item = attachment
                                .get("item")
                                .and_then(|v| v.as_str())
                                .unwrap_or_default()
                                .to_string();

                            item = if item.starts_with("ipfs://") {
                                let hash = item.trim_start_matches("ipfs://");
                                format!("{}/ipfs/{}", INFURA_GATEWAY, hash)
                            } else {
                                item.to_string()
                            };

                            let response = reqwest::get(&item).await?;
                            let image_bytes = response.bytes().await?;
                            item = general_purpose::STANDARD.encode(&image_bytes)
                        }

                        _ => {
                            attachment_type = "Unknown".to_string();
                        }
                    }
                }
            }
        }

        match if model == "Claude" {
            call_quote_completion_claude(
                &content,
                custom_instructions,
                collection_instructions,
                &collection.description,
                &attachment_type,
                &item,
            )
            .await
        } else {
            call_quote_completion_openai(
                &content,
                custom_instructions,
                collection_instructions,
                &collection.description,
                &attachment_type,
                &item,
            )
            .await
        } {
            Ok((llm_response, image)) => {
                match format_response(&llm_response, &collection, image).await {
                    Ok(content) => {
                        let _ = make_quote(
                            &content,
                            private_key,
                            auth_tokens,
                            post["id"].as_str().unwrap_or_default(),
                        )
                        .await;
                    }
                    Err(err) => {
                        println!("Error with Quote format {:?}", err);
                    }
                }
            }
            Err(err) => {
                println!("Error with LLM Quote {:?}", err);
            }
        }
        Ok::<(), Box<dyn Error + Send + Sync>>(())
    });

    let results: Vec<_> = join_all(quote_futures).await;

    for result in results {
        if let Err(e) = result {
            println!("Error with quoting: {:?}", e);
        }
    }

    Ok(())
}

async fn format_response(
    llm_message: &str,
    collection: &Collection,
    use_image: bool,
) -> Result<String, Box<dyn Error + Send + Sync>> {
    let mut focus = String::from("TEXT_ONLY");
    let mut schema = "https://json-schemas.lens.dev/posts/text-only/3.0.0.json".to_string();
    let mut image = None;

    if use_image {
        focus = String::from("IMAGE");
        schema = "https://json-schemas.lens.dev/posts/image/3.0.0.json".to_string();
        image = Some(Image {
            tipo: "image/png".to_string(),
            item: collection.image.clone(),
        })
    }
    let tags = vec![
        "tripleA".to_string(),
        collection.title.to_string().replace(" ", "").to_lowercase(),
    ];

    let publication = Publication {
        schema,
        lens: Content {
            mainContentFocus: focus,
            title: llm_message.chars().take(20).collect(),
            content: llm_message.to_string(),
            id: Uuid::new_v4().to_string(),
            locale: "en".to_string(),
            tags,
            image,
        },
    };

    let publication_json = to_string(&publication)?;

    let content = match upload_lens_storage(publication_json).await {
        Ok(con) => con,
        Err(e) => {
            eprintln!("Error uploading content to Lens Storage: {}", e);
            return Err(Box::new(io::Error::new(
                io::ErrorKind::Other,
                format!("Error uploading content to Lens Storage: {}", e),
            )));
        }
    };

    Ok(content)
}

async fn feed_posts(
    collection: &Collection,
    auth_tokens: &str,
    private_key: u32,
    feeds: Vec<String>,
    model: &str,
    custom_instructions: &str,
    collection_instructions: &str,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    let feed_futures = feeds.into_iter().map(|feed| async move {
        match feed_info(&feed).await {
            Ok((title, description)) => {
                match if model == "Claude" {
                    call_feed_completion_claude(
                        &collection,
                        custom_instructions,
                        collection_instructions,
                        &description,
                        &title,
                    )
                    .await
                } else {
                    call_feed_completion_openai(
                        &collection,
                        custom_instructions,
                        collection_instructions,
                        &description,
                        &title,
                    )
                    .await
                } {
                    Ok(llm_response) => {
                        match format_response(&llm_response, &collection, true).await {
                            Ok(content) => {
                                let _ = make_publication(
                                    &content,
                                    private_key,
                                    auth_tokens,
                                    Some(feed),
                                )
                                .await;
                            }
                            Err(err) => {
                                println!("Error with Feed format {:?}", err);
                            }
                        }
                    }
                    Err(err) => {
                        println!("Error with LLM Feed {:?}", err);
                    }
                }
            }
            Err(err) => {
                println!("Error with LLM Feed {:?}", err);
            }
        }

        Ok::<(), Box<dyn Error + Send + Sync>>(())
    });

    let results: Vec<_> = join_all(feed_futures).await;

    for result in results {
        if let Err(e) = result {
            println!("Error with feed: {:?}", e);
        }
    }

    Ok(())
}
