use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "veo-3.0-generate-001";
const API_BASE: &str = "https://generativelanguage.googleapis.com/v1beta";
const POLL_INTERVAL_SECS: u64 = 10;
const MAX_POLL_ATTEMPTS: u32 = 60; // 10 minutes at 10s intervals

pub struct VeoProvider;

#[async_trait::async_trait]
impl MediaProvider for VeoProvider {
    async fn generate(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let model = if options.model.is_empty() || options.model == "default" {
            DEFAULT_MODEL
        } else {
            &options.model
        };

        let aspect_ratio = options
            .aspect_ratio
            .as_deref()
            .or_else(|| options.provider_options.get("aspectRatio").and_then(|v| v.as_str()))
            .unwrap_or("16:9");

        // duration_seconds from GenerationOptions takes precedence over provider_options
        let duration = options
            .duration_seconds
            .map(|d| d as u64)
            .or_else(|| {
                options
                    .provider_options
                    .get("durationSeconds")
                    .and_then(|v| v.as_u64().or_else(|| v.as_str().and_then(|s| s.parse().ok())))
            })
            .unwrap_or(8);

        let resolution = options
            .provider_options
            .get("resolution")
            .and_then(|v| v.as_str())
            .unwrap_or("720p");

        let person_generation = options
            .provider_options
            .get("personGeneration")
            .and_then(|v| v.as_str())
            .unwrap_or("allow_all");

        let mut instances = json!({
            "prompt": prompt_text,
        });

        // Image-to-video: first attachment as initial frame
        if let Some(att) = attachments.first() {
            instances["image"] = json!({
                "bytesBase64Encoded": att.data_b64,
                "mimeType": att.mime_type,
            });
        }

        let parameters = json!({
            "aspectRatio": aspect_ratio,
            "durationSeconds": duration,
            "resolution": resolution,
            "personGeneration": person_generation,
        });

        let body = json!({
            "instances": [instances],
            "parameters": parameters,
        });

        let url = format!(
            "{}/models/{}:predictLongRunning?key={}",
            API_BASE, model, api_key
        );

        if options.verbose {
            ui::verbose(&format!(
                "POST {}/models/{}:predictLongRunning?key=***",
                API_BASE, model
            ));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Prompt: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            ui::verbose(&format!(
                "Model: {}, duration: {}s, aspect: {}, resolution: {}",
                model, duration, aspect_ratio, resolution
            ));
        }

        let client = reqwest::Client::new();

        let resp = client
            .post(&url)
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(30))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error submitting to Veo: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "Google AI authentication failed ({}): {}\n  Check your GEMINI_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "Veo API error ({}): {}",
                status.as_u16(),
                &body_text[..body_text.len().min(300)]
            ));
            return Ok(false);
        }

        let result: serde_json::Value = response.json().await?;
        let operation_name = result["name"]
            .as_str()
            .ok_or_else(|| color_eyre::eyre::eyre!("No operation name in Veo response: {}", result))?;

        if options.verbose {
            ui::verbose(&format!("Operation: {}", operation_name));
        }
        ui::info(&format!("Veo operation {} — polling for completion", operation_name));

        let poll_url = format!("{}/{}?key={}", API_BASE, operation_name, api_key);

        for attempt in 1..=MAX_POLL_ATTEMPTS {
            tokio::time::sleep(Duration::from_secs(POLL_INTERVAL_SECS)).await;

            let poll_resp = client
                .get(&poll_url)
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
            let done = poll_result["done"].as_bool().unwrap_or(false);

            if done {
                // Check for error
                if let Some(error) = poll_result.get("error") {
                    let msg = error["message"].as_str().unwrap_or("unknown error");
                    ui::fail_msg(&format!("Veo generation failed: {}", msg));
                    return Ok(false);
                }

                let samples = poll_result["response"]["generateVideoResponse"]["generatedSamples"]
                    .as_array();

                if let Some(samples) = samples {
                    if let Some(first) = samples.first() {
                        let video_uri = first["video"]["uri"]
                            .as_str()
                            .unwrap_or("");

                        if video_uri.is_empty() {
                            ui::fail_msg("Veo returned done but no video URI");
                            return Ok(false);
                        }

                        let authenticated_uri = if video_uri.contains('?') {
                            format!("{}&key={}", video_uri, api_key)
                        } else {
                            format!("{}?key={}", video_uri, api_key)
                        };
                        return download_file(&authenticated_uri, output_path, &client, options.verbose).await;
                    }
                }

                ui::fail_msg("Veo returned done but no generated samples");
                return Ok(false);
            }

            if options.verbose && attempt % 3 == 0 {
                ui::verbose(&format!(
                    "Still processing (poll {}/{})",
                    attempt, MAX_POLL_ATTEMPTS
                ));
            }
        }

        ui::fail_msg(&format!(
            "Veo operation {} timed out after {} polls",
            operation_name, MAX_POLL_ATTEMPTS
        ));
        Ok(false)
    }

    fn name(&self) -> &str {
        "veo"
    }
}

async fn download_file(
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
        .timeout(Duration::from_secs(300))
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
