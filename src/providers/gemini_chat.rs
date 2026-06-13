use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{ChatProvider, GenerationOptions};
use crate::ui;

pub struct GeminiChatProvider;

#[async_trait::async_trait]
impl ChatProvider for GeminiChatProvider {
    async fn generate(
        &self,
        system_prompt: &str,
        user_prompt: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let url = format!(
            "https://generativelanguage.googleapis.com/v1beta/models/{}:generateContent?key={}",
            options.model, api_key
        );

        let max_tokens = options
            .provider_options
            .get("max_tokens")
            .and_then(|v| v.as_u64())
            .unwrap_or(4096);

        let mut parts: Vec<serde_json::Value> = Vec::new();

        for att in attachments {
            if att.mime_type.starts_with("image/") {
                parts.push(json!({
                    "inline_data": {
                        "mime_type": att.mime_type,
                        "data": att.data_b64,
                    }
                }));
            }
        }

        parts.push(json!({ "text": user_prompt }));

        let mut body = json!({
            "contents": [{ "parts": parts }],
            "generationConfig": {
                "maxOutputTokens": max_tokens,
            },
        });

        if let Some(budget) = options.provider_options.get("thinking_budget").and_then(|v| v.as_u64()) {
            body["generationConfig"]["thinkingConfig"] = json!({
                "thinkingBudget": budget,
            });
        }

        if !system_prompt.is_empty() {
            body["systemInstruction"] = json!({
                "parts": [{ "text": system_prompt }]
            });
        }

        if let Some(temp) = options.provider_options.get("temperature").and_then(|v| v.as_f64()) {
            body["generationConfig"]["temperature"] = json!(temp);
        }

        if options.verbose {
            ui::verbose(&format!(
                "POST {}?key=***",
                url.split('?').next().unwrap_or(&url)
            ));
            let preview: String = user_prompt.chars().take(120).collect();
            ui::verbose(&format!(
                "Prompt: {}{}",
                preview,
                if user_prompt.len() > 120 { "..." } else { "" }
            ));
        }

        let client = reqwest::Client::new();
        let resp = client
            .post(&url)
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
                let text = result["candidates"]
                    .as_array()
                    .and_then(|arr| arr.first())
                    .and_then(|c| c["content"]["parts"].as_array())
                    .and_then(|parts| parts.first())
                    .and_then(|part| part["text"].as_str());

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
        "gemini-chat"
    }
}
