use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{ChatProvider, GenerationOptions};
use crate::ui;

pub struct OpenAiChatProvider;

#[async_trait::async_trait]
impl ChatProvider for OpenAiChatProvider {
    async fn generate(
        &self,
        system_prompt: &str,
        user_prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        openai_compatible_generate(
            "https://api.openai.com/v1/chat/completions",
            system_prompt,
            user_prompt,
            output_path,
            api_key,
            options,
            attachments,
        )
        .await
    }

    fn name(&self) -> &str {
        "openai-chat"
    }
}

pub async fn openai_compatible_generate(
    url: &str,
    system_prompt: &str,
    user_prompt: &str,
    output_path: &Path,
    api_key: &str,
    options: &GenerationOptions,
    attachments: &[LoadedAttachment],
) -> color_eyre::Result<bool> {
    let max_tokens = options
        .provider_options
        .get("max_tokens")
        .and_then(|v| v.as_u64())
        .unwrap_or(4096);

    let mut messages: Vec<serde_json::Value> = Vec::new();

    if !system_prompt.is_empty() {
        messages.push(json!({
            "role": "system",
            "content": system_prompt,
        }));
    }

    let image_attachments: Vec<&LoadedAttachment> = attachments
        .iter()
        .filter(|a| a.mime_type.starts_with("image/"))
        .collect();

    if image_attachments.is_empty() {
        messages.push(json!({
            "role": "user",
            "content": user_prompt,
        }));
    } else {
        let mut content_parts: Vec<serde_json::Value> = Vec::new();
        for att in &image_attachments {
            content_parts.push(json!({
                "type": "image_url",
                "image_url": {
                    "url": format!("data:{};base64,{}", att.mime_type, att.data_b64),
                }
            }));
        }
        content_parts.push(json!({
            "type": "text",
            "text": user_prompt,
        }));
        messages.push(json!({
            "role": "user",
            "content": content_parts,
        }));
    }

    let mut body = json!({
        "model": options.model,
        "max_tokens": max_tokens,
        "messages": messages,
    });

    if let Some(temp) = options.provider_options.get("temperature").and_then(|v| v.as_f64()) {
        body["temperature"] = json!(temp);
    }
    if let Some(top_p) = options.provider_options.get("top_p").and_then(|v| v.as_f64()) {
        body["top_p"] = json!(top_p);
    }

    if options.verbose {
        ui::verbose(&format!("POST {}", url));
        let preview: String = user_prompt.chars().take(120).collect();
        ui::verbose(&format!(
            "Prompt: {}{}",
            preview,
            if user_prompt.len() > 120 { "..." } else { "" }
        ));
    }

    let client = reqwest::Client::new();
    let resp = client
        .post(url)
        .header("Authorization", format!("Bearer {}", api_key))
        .header("Content-Type", "application/json")
        .json(&body)
        .timeout(Duration::from_secs(120))
        .send()
        .await;

    match resp {
        Ok(response) => {
            let status = response.status();
            if !status.is_success() {
                let error_body = response.text().await.unwrap_or_default();
                let preview: String = error_body.chars().take(300).collect();
                ui::fail_msg(&format!("HTTP {} for {}: {}", status.as_u16(), output_path.display(), preview));
                return Ok(false);
            }

            let result: serde_json::Value = response.json().await?;
            let text = result["choices"]
                .as_array()
                .and_then(|arr| arr.first())
                .and_then(|c| c["message"]["content"].as_str());

            match text {
                Some(content) => {
                    let sanitized = crate::providers::sanitize_chat_output(content, output_path);
                    if let Some(parent) = output_path.parent() {
                        std::fs::create_dir_all(parent)?;
                    }
                    std::fs::write(output_path, sanitized)?;
                    Ok(true)
                }
                None => {
                    ui::fail_msg(&format!("No text content in response for {}", output_path.display()));
                    Ok(false)
                }
            }
        }
        Err(e) => {
            ui::fail_msg(&format!("Network error for {}: {}", output_path.display(), e));
            Ok(false)
        }
    }
}
