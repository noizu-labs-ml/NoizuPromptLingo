use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{ChatProvider, GenerationOptions};
use crate::ui;

pub struct AnthropicProvider;

#[async_trait::async_trait]
impl ChatProvider for AnthropicProvider {
    async fn generate(
        &self,
        system_prompt: &str,
        user_prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let url = "https://api.anthropic.com/v1/messages";

        let max_tokens = options
            .provider_options
            .get("max_tokens")
            .and_then(|v| v.as_u64())
            .unwrap_or(4096);

        let mut content_parts: Vec<serde_json::Value> = Vec::new();

        for att in attachments {
            if att.mime_type.starts_with("image/") {
                content_parts.push(json!({
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": att.mime_type,
                        "data": att.data_b64,
                    }
                }));
            }
        }

        content_parts.push(json!({
            "type": "text",
            "text": user_prompt,
        }));

        let mut body = json!({
            "model": options.model,
            "max_tokens": max_tokens,
            "messages": [{
                "role": "user",
                "content": content_parts,
            }],
        });

        if !system_prompt.is_empty() {
            body["system"] = json!(system_prompt);
        }

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
            .header("x-api-key", api_key)
            .header("anthropic-version", "2023-06-01")
            .header("content-type", "application/json")
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
                let text = result["content"]
                    .as_array()
                    .and_then(|arr| arr.first())
                    .and_then(|block| block["text"].as_str());

                match text {
                    Some(content) => {
                        let sanitized = super::sanitize_chat_output(content, output_path);
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

    fn name(&self) -> &str {
        "anthropic"
    }
}
