use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "eleven_multilingual_v2";
const DEFAULT_VOICE_ID: &str = "21m00Tcm4TlvDq8ikWAM"; // Rachel
const API_BASE: &str = "https://api.elevenlabs.io/v1/text-to-speech";

pub struct ElevenLabsProvider;

#[async_trait::async_trait]
impl MediaProvider for ElevenLabsProvider {
    async fn generate(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        _attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let model_id = if options.model.is_empty() || options.model == "default" {
            DEFAULT_MODEL
        } else {
            &options.model
        };

        let voice_id = options
            .provider_options
            .get("voice_id")
            .and_then(|v| v.as_str())
            .unwrap_or(DEFAULT_VOICE_ID);

        let output_format = match output_path.extension().and_then(|e| e.to_str()) {
            Some("wav") => "wav_44100",
            Some("ogg" | "opus") => "opus_48000_128",
            Some("pcm") => "pcm_44100",
            _ => "mp3_44100_128",
        };

        let url = format!("{}/{}?output_format={}", API_BASE, voice_id, output_format);

        let mut body = json!({
            "text": prompt_text,
            "model_id": model_id,
        });

        // Voice settings
        let mut voice_settings = serde_json::Map::new();
        if let Some(stability) = options.provider_options.get("stability").and_then(|v| v.as_f64()) {
            voice_settings.insert("stability".into(), json!(stability));
        }
        if let Some(similarity) = options.provider_options.get("similarity_boost").and_then(|v| v.as_f64()) {
            voice_settings.insert("similarity_boost".into(), json!(similarity));
        }
        if let Some(style) = options.provider_options.get("style").and_then(|v| v.as_f64()) {
            voice_settings.insert("style".into(), json!(style));
        }
        if let Some(speed) = options.provider_options.get("speed").and_then(|v| v.as_f64()) {
            voice_settings.insert("speed".into(), json!(speed));
        }
        if let Some(boost) = options.provider_options.get("use_speaker_boost").and_then(|v| v.as_bool()) {
            voice_settings.insert("use_speaker_boost".into(), json!(boost));
        }
        if !voice_settings.is_empty() {
            body["voice_settings"] = serde_json::Value::Object(voice_settings);
        }

        if let Some(lang) = options.provider_options.get("language_code").and_then(|v| v.as_str()) {
            body["language_code"] = json!(lang);
        }

        if let Some(seed) = options.provider_options.get("seed").and_then(|v| v.as_u64()) {
            body["seed"] = json!(seed);
        }

        if options.verbose {
            ui::verbose(&format!("POST {}/{}?output_format={}", API_BASE, voice_id, output_format));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Text: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            ui::verbose(&format!("Model: {}, voice_id: {}", model_id, voice_id));
        }

        let client = reqwest::Client::new();
        let resp = client
            .post(&url)
            .header("xi-api-key", api_key)
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(120))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error calling ElevenLabs: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "ElevenLabs authentication failed ({}): {}\n  Check your ELEVENLABS_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "ElevenLabs error ({}): {}",
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
        "elevenlabs"
    }
}
