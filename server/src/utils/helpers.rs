use ethers::types::U256;
use regex::Regex;
use std::error::Error;
use crate::utils::types::TripleAAgent;

pub fn extract_values_prompt(
    input: &str,
) -> Result<(String, String), Box<dyn Error + Send + Sync>> {
    let image_prompt_re = Regex::new(r"(?m)^Image Prompt:\s*(.+)")?;
    let model_re = Regex::new(r"(?m)^Model:\s*(\d+)")?;

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
) -> Result<(String, String, U256, Vec<U256>), Box<dyn Error + Send + Sync>> {
    let title_re = Regex::new(r"(?m)^Title:\s*(.+)")?;
    let description_re = Regex::new(r"(?m)^Description:\s*(.+)")?;
    let amount_re = Regex::new(r"(?m)^Amount:\s*(\d+)")?;
    let mona_re = Regex::new(r"(?m)^Mona:\s*(\d+)")?;
    let grass_re = Regex::new(r"(?m)^Grass:\s*(\d+)")?;
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

    let mona: u64 = mona_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| m.as_str().parse::<u64>().ok())
        .unwrap_or_default();

    let grass: u64 = grass_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| m.as_str().parse::<u64>().ok())
        .unwrap_or_default();

    let bonsai: u64 = bonsai_re
        .captures(input)
        .and_then(|cap| cap.get(1))
        .and_then(|m| m.as_str().parse::<u64>().ok())
        .unwrap_or_default();

    Ok((
        title,
        description,
        U256::from(amount),
        vec![U256::from(mona), U256::from(grass), U256::from(bonsai)],
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
    format!(r#"
Custom Instructions: {}
Lore: {}
Knowledge: {}
Style: {}
Adjectives: {}
"#, agent.custom_instructions, agent.lore, agent.knowledge, agent.style, agent.adjectives)
}
