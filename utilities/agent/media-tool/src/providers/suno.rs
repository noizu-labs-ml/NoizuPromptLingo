use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "V4_5ALL";
const POLL_INTERVAL_SECS: u64 = 10;
const MAX_POLL_ATTEMPTS: u32 = 120; // 20 minutes at 10s intervals
const API_BASE: &str = "https://api.sunoapi.org";

pub struct SunoProvider;

#[async_trait::async_trait]
impl MediaProvider for SunoProvider {
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

        let is_sfx = model.contains("SOUND") || model.contains("sfx")
            || model.to_lowercase() == "sound";

        let callback_url = options
            .provider_options
            .get("callBackUrl")
            .and_then(|v| v.as_str())
            .unwrap_or("https://httpbin.org/post");

        // SFX uses a separate endpoint and request shape
        let (url, body) = if is_sfx {
            let sfx_model = "V5";
            let sound_loop = options.provider_options.get("soundLoop")
                .and_then(|v| v.as_bool()).unwrap_or(false);
            let sound_tempo = options.provider_options.get("soundTempo")
                .and_then(|v| v.as_u64()).unwrap_or(120) as u32;
            let sound_key = options.provider_options.get("soundKey")
                .and_then(|v| v.as_str()).unwrap_or("Any");

            let mut b = json!({
                "prompt": prompt_text,
                "model": sfx_model,
                "soundLoop": sound_loop,
                "soundTempo": sound_tempo,
                "soundKey": sound_key,
                "grabLyrics": false,
                "callBackUrl": callback_url,
            });

            if let Some(dur) = options.duration_seconds {
                b["duration"] = json!(dur as u32);
            }

            (format!("{}/api/v1/generate/sounds", API_BASE), b)
        } else {
            // Music generation
            let has_style = options.provider_options.get("style").and_then(|v| v.as_str()).is_some();
            let custom_mode = options
                .provider_options
                .get("customMode")
                .and_then(|v| v.as_bool())
                .unwrap_or(has_style || prompt_text.len() > 200);

            let instrumental = options
                .provider_options
                .get("instrumental")
                .and_then(|v| v.as_bool())
                .unwrap_or(true);

            let mut b = json!({
                "prompt": prompt_text,
                "model": model,
                "customMode": custom_mode,
                "instrumental": instrumental,
                "callBackUrl": callback_url,
            });

            if custom_mode {
                if let Some(style) = options.provider_options.get("style").and_then(|v| v.as_str()) {
                    b["style"] = json!(style);
                }
                if let Some(title) = options.provider_options.get("title").and_then(|v| v.as_str()) {
                    b["title"] = json!(title);
                }
                if let Some(pid) = options.provider_options.get("personaId").and_then(|v| v.as_str()) {
                    b["personaId"] = json!(pid);
                }
                if let Some(pm) = options.provider_options.get("personaModel").and_then(|v| v.as_str()) {
                    b["personaModel"] = json!(pm);
                }
            }

            if let Some(dur) = options.duration_seconds {
                b["duration"] = json!(dur as u32);
            }

            if let Some(neg) = options.negative_prompt.as_deref().or_else(|| {
                options.provider_options.get("negativeTags").and_then(|v| v.as_str())
            }) {
                b["negativeTags"] = json!(neg);
            }

            if let Some(vg) = options.provider_options.get("vocalGender").and_then(|v| v.as_str()) {
                b["vocalGender"] = json!(vg);
            }

            for float_key in &["styleWeight", "weirdnessConstraint", "audioWeight"] {
                if let Some(val) = options.provider_options.get(*float_key).and_then(|v| v.as_f64()) {
                    b[*float_key] = json!(val);
                }
            }

            (format!("{}/api/v1/generate", API_BASE), b)
        };

        if options.verbose {
            ui::verbose(&format!("POST {}", url));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Prompt: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            if is_sfx {
                ui::verbose(&format!("Model: V5 (sound generation), sfx=true"));
            } else {
                ui::verbose(&format!("Model: {}", model));
            }
        }

        let client = reqwest::Client::new();

        // Submit generation request
        let resp = client
            .post(&url)
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(30))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error submitting to Suno: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "Suno authentication failed ({}): {}\n  Check your SUNO_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "Suno API error ({}): {}",
                status.as_u16(),
                &body_text[..body_text.len().min(300)]
            ));
            return Ok(false);
        }

        let result: serde_json::Value = response.json().await?;
        let task_id = result["data"]["taskId"]
            .as_str()
            .ok_or_else(|| color_eyre::eyre::eyre!("No taskId in Suno response: {}", result))?;

        if options.verbose {
            ui::verbose(&format!("Task submitted: {}", task_id));
        }
        ui::info(&format!("Suno task {} — polling for completion", task_id));

        // Poll for completion
        let poll_url = format!("{}/api/v1/generate/record-info?taskId={}", API_BASE, task_id);

        for attempt in 1..=MAX_POLL_ATTEMPTS {
            tokio::time::sleep(Duration::from_secs(POLL_INTERVAL_SECS)).await;

            let poll_resp = client
                .get(&poll_url)
                .header("Authorization", format!("Bearer {}", api_key))
                .timeout(Duration::from_secs(30))
                .send()
                .await;

            let poll_response = match poll_resp {
                Ok(r) => r,
                Err(e) => {
                    if options.verbose {
                        ui::verbose(&format!("Poll attempt {} failed: {}", attempt, e));
                    }
                    continue;
                }
            };

            if !poll_response.status().is_success() {
                if options.verbose {
                    ui::verbose(&format!("Poll attempt {} returned {}", attempt, poll_response.status()));
                }
                continue;
            }

            let poll_result: serde_json::Value = poll_response.json().await?;
            let status_str = poll_result["data"]["status"]
                .as_str()
                .unwrap_or("UNKNOWN");

            match status_str {
                "SUCCESS" => {
                    if options.verbose {
                        let preview = serde_json::to_string_pretty(&poll_result).unwrap_or_default();
                        let truncated: String = preview.chars().take(1000).collect();
                        ui::verbose(&format!("Suno SUCCESS response: {}", truncated));
                    }

                    // Try multiple known response shapes
                    let tracks = poll_result["data"]["response"]["sunoData"]
                        .as_array()
                        .or_else(|| poll_result["data"]["response"]["data"].as_array())
                        .or_else(|| poll_result["data"]["data"].as_array());

                    if let Some(tracks) = tracks {
                        if let Some(first) = tracks.first() {
                            let audio_url = first["audioUrl"]
                                .as_str()
                                .or_else(|| first["audio_url"].as_str())
                                .unwrap_or("");
                            if audio_url.is_empty() {
                                ui::fail_msg("Suno returned SUCCESS but no audio_url");
                                return Ok(false);
                            }

                            if options.verbose {
                                if let Some(title) = first["title"].as_str() {
                                    ui::verbose(&format!("Title: {}", title));
                                }
                                if let Some(dur) = first["duration"].as_f64() {
                                    ui::verbose(&format!("Duration: {:.1}s", dur));
                                }
                                if let Some(tags) = first["tags"].as_str() {
                                    ui::verbose(&format!("Tags: {}", tags));
                                }
                            }

                            return self.download_audio(audio_url, output_path, &client, options.verbose).await;
                        }
                    }

                    ui::fail_msg("Suno returned SUCCESS but no tracks in response");
                    return Ok(false);
                }
                "FAILED" => {
                    ui::fail_msg(&format!("Suno generation failed for task {}", task_id));
                    if options.verbose {
                        let preview = serde_json::to_string_pretty(&poll_result).unwrap_or_default();
                        ui::verbose(&preview[..preview.len().min(500)]);
                    }
                    return Ok(false);
                }
                "PENDING" | "GENERATING" | "TEXT_SUCCESS" | "FIRST_SUCCESS" => {
                    if options.verbose && attempt % 3 == 0 {
                        ui::verbose(&format!(
                            "Still {} (poll {}/{})",
                            status_str, attempt, MAX_POLL_ATTEMPTS
                        ));
                    }
                }
                _ => {
                    if options.verbose {
                        ui::verbose(&format!("Unknown status: {}", status_str));
                    }
                }
            }
        }

        ui::fail_msg(&format!(
            "Suno task {} timed out after {} polls",
            task_id, MAX_POLL_ATTEMPTS
        ));
        Ok(false)
    }

    fn name(&self) -> &str {
        "suno"
    }
}

impl SunoProvider {
    async fn download_audio(
        &self,
        url: &str,
        output_path: &Path,
        client: &reqwest::Client,
        verbose: bool,
    ) -> color_eyre::Result<bool> {
        if verbose {
            ui::verbose(&format!("Downloading: {}", url));
        }

        let resp = client
            .get(url)
            .timeout(Duration::from_secs(120))
            .send()
            .await;

        match resp {
            Ok(response) => {
                if !response.status().is_success() {
                    ui::fail_msg(&format!("Download failed: HTTP {}", response.status()));
                    return Ok(false);
                }

                let bytes = response.bytes().await?;
                if let Some(parent) = output_path.parent() {
                    std::fs::create_dir_all(parent)?;
                }
                std::fs::write(output_path, &bytes)?;
                Ok(true)
            }
            Err(e) => {
                ui::fail_msg(&format!("Download error: {}", e));
                Ok(false)
            }
        }
    }
}
