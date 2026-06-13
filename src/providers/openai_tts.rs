use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "gpt-4o-mini-tts";
const DEFAULT_VOICE: &str = "alloy";
const API_URL: &str = "https://api.openai.com/v1/audio/speech";

pub struct OpenAiTtsProvider;

#[async_trait::async_trait]
impl MediaProvider for OpenAiTtsProvider {
    async fn generate(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        _attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let model = if options.model.is_empty() || options.model == "default" {
            DEFAULT_MODEL
        } else {
            &options.model
        };

        let voice = options
            .provider_options
            .get("voice")
            .and_then(|v| v.as_str())
            .unwrap_or(DEFAULT_VOICE);

        let response_format = output_path
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("mp3");

        let mut body = json!({
            "model": model,
            "input": prompt_text,
            "voice": voice,
            "response_format": response_format,
        });

        if let Some(speed) = options.provider_options.get("speed").and_then(|v| v.as_f64()) {
            body["speed"] = json!(speed);
        }

        // instructions only supported by gpt-4o-mini-tts
        if let Some(instructions) = options.provider_options.get("instructions").and_then(|v| v.as_str()) {
            body["instructions"] = json!(instructions);
        }

        if let Some(lang) = options.provider_options.get("language").and_then(|v| v.as_str()) {
            body["language"] = json!(lang);
        }

        if options.verbose {
            ui::verbose(&format!("POST {}", API_URL));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Input: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            ui::verbose(&format!("Model: {}, voice: {}, format: {}", model, voice, response_format));
        }

        let client = reqwest::Client::new();
        let resp = client
            .post(API_URL)
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(120))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error calling OpenAI TTS: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "OpenAI authentication failed ({}): {}\n  Check your OPENAI_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "OpenAI TTS error ({}): {}",
                status.as_u16(),
                &body_text[..body_text.len().min(300)]
            ));
            return Ok(false);
        }

        let bytes = response.bytes().await?;
        if let Some(parent) = output_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::write(output_path, &bytes)?;
        Ok(true)
    }

    fn name(&self) -> &str {
        "openai-tts"
    }
}
