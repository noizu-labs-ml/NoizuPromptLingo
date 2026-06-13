use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "qwen3-tts-flash";
const DEFAULT_VOICE: &str = "Cherry";
const API_URL_INTL: &str = "https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation";
const API_URL_CN: &str = "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation";

pub struct QwenTtsProvider;

#[async_trait::async_trait]
impl MediaProvider for QwenTtsProvider {
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

        let language = options
            .provider_options
            .get("language")
            .and_then(|v| v.as_str())
            .unwrap_or("English");

        let region = options
            .provider_options
            .get("region")
            .and_then(|v| v.as_str())
            .unwrap_or("intl");

        let api_url = if region == "cn" { API_URL_CN } else { API_URL_INTL };

        let mut input = json!({
            "text": prompt_text,
            "voice": voice,
            "language_type": language,
        });

        if let Some(instructions) = options.provider_options.get("instructions").and_then(|v| v.as_str()) {
            input["instructions"] = json!(instructions);
        }

        let body = json!({
            "model": model,
            "input": input,
        });

        if options.verbose {
            ui::verbose(&format!("POST {}", api_url));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Text: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            ui::verbose(&format!("Model: {}, voice: {}, lang: {}", model, voice, language));
        }

        let client = reqwest::Client::new();
        let resp = client
            .post(api_url)
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(120))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error calling Qwen TTS: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "Qwen/DashScope authentication failed ({}): {}\n  Check your DASHSCOPE_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "Qwen TTS error ({}): {}",
                status.as_u16(),
                &body_text[..body_text.len().min(300)]
            ));
            return Ok(false);
        }

        let result: serde_json::Value = response.json().await?;

        // Extract audio URL from response
        let audio_url = result["output"]["audio"]["url"]
            .as_str()
            .ok_or_else(|| color_eyre::eyre::eyre!("No audio URL in Qwen TTS response: {}", result))?;

        if options.verbose {
            ui::verbose(&format!("Downloading audio from: {}", audio_url));
        }

        // Download the audio file
        let audio_resp = client
            .get(audio_url)
            .timeout(Duration::from_secs(120))
            .send()
            .await;

        match audio_resp {
            Ok(r) => {
                if !r.status().is_success() {
                    ui::fail_msg(&format!("Audio download failed: HTTP {}", r.status()));
                    return Ok(false);
                }
                let bytes = r.bytes().await?;
                if let Some(parent) = output_path.parent() {
                    std::fs::create_dir_all(parent)?;
                }
                std::fs::write(output_path, &bytes)?;
                Ok(true)
            }
            Err(e) => {
                ui::fail_msg(&format!("Audio download error: {}", e));
                Ok(false)
            }
        }
    }

    fn name(&self) -> &str {
        "qwen-tts"
    }
}
