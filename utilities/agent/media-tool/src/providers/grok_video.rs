use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const DEFAULT_MODEL: &str = "grok-imagine-video";
const API_BASE: &str = "https://api.x.ai/v1";
const POLL_INTERVAL_SECS: u64 = 5;
const MAX_POLL_ATTEMPTS: u32 = 180; // 15 minutes at 5s intervals

pub struct GrokVideoProvider;

#[async_trait::async_trait]
impl MediaProvider for GrokVideoProvider {
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

        let duration = options
            .provider_options
            .get("duration")
            .and_then(|v| v.as_u64())
            .unwrap_or(10);

        let aspect_ratio = options
            .aspect_ratio
            .as_deref()
            .or_else(|| options.provider_options.get("aspect_ratio").and_then(|v| v.as_str()))
            .unwrap_or("16:9");

        let resolution = options
            .provider_options
            .get("resolution")
            .and_then(|v| v.as_str())
            .unwrap_or("720p");

        let mut body = json!({
            "model": model,
            "prompt": prompt_text,
            "duration": duration,
            "aspect_ratio": aspect_ratio,
            "resolution": resolution,
        });

        // Image-to-video: use first attachment as source image
        if let Some(att) = attachments.first() {
            body["image"] = json!({
                "url": format!("data:{};base64,{}", att.mime_type, att.data_b64),
            });
        }

        let url = format!("{}/videos/generations", API_BASE);

        if options.verbose {
            ui::verbose(&format!("POST {}", url));
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
            .header("Authorization", format!("Bearer {}", api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(30))
            .send()
            .await;

        let response = match resp {
            Ok(r) => r,
            Err(e) => {
                ui::fail_msg(&format!("Network error submitting to Grok Video: {}", e));
                return Ok(false);
            }
        };

        let status = response.status();
        if status.as_u16() == 401 || status.as_u16() == 403 {
            let body_text = response.text().await.unwrap_or_default();
            color_eyre::eyre::bail!(
                "xAI authentication failed ({}): {}\n  Check your XAI_API_KEY",
                status.as_u16(),
                &body_text[..body_text.len().min(200)]
            );
        }
        if !status.is_success() {
            let body_text = response.text().await.unwrap_or_default();
            ui::fail_msg(&format!(
                "Grok Video API error ({}): {}",
                status.as_u16(),
                &body_text[..body_text.len().min(300)]
            ));
            return Ok(false);
        }

        let result: serde_json::Value = response.json().await?;
        let request_id = result["request_id"]
            .as_str()
            .ok_or_else(|| color_eyre::eyre::eyre!("No request_id in Grok response: {}", result))?;

        if options.verbose {
            ui::verbose(&format!("Request submitted: {}", request_id));
        }
        ui::info(&format!("Grok video {} — polling for completion", request_id));

        let poll_url = format!("{}/videos/{}", API_BASE, request_id);

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
            let status_str = poll_result["status"]
                .as_str()
                .unwrap_or("unknown");

            match status_str {
                "done" => {
                    let video_url = poll_result["video"]["url"]
                        .as_str()
                        .unwrap_or("");

                    if video_url.is_empty() {
                        ui::fail_msg("Grok returned done but no video URL");
                        return Ok(false);
                    }

                    if options.verbose {
                        if let Some(dur) = poll_result["video"]["duration"].as_f64() {
                            ui::verbose(&format!("Duration: {:.1}s", dur));
                        }
                    }

                    return download_file(video_url, output_path, &client, options.verbose).await;
                }
                "failed" => {
                    let err_msg = poll_result["error"]["message"]
                        .as_str()
                        .unwrap_or("unknown error");
                    ui::fail_msg(&format!("Grok video generation failed: {}", err_msg));
                    return Ok(false);
                }
                "expired" => {
                    ui::fail_msg(&format!("Grok video request {} expired", request_id));
                    return Ok(false);
                }
                "pending" => {
                    if options.verbose && attempt % 6 == 0 {
                        ui::verbose(&format!(
                            "Still pending (poll {}/{})",
                            attempt, MAX_POLL_ATTEMPTS
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
            "Grok video {} timed out after {} polls",
            request_id, MAX_POLL_ATTEMPTS
        ));
        Ok(false)
    }

    fn name(&self) -> &str {
        "grok-video"
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
