use std::path::Path;
use std::time::Duration;

use base64::Engine;
use serde_json::json;

use crate::attachments::LoadedAttachment;
use crate::providers::{GenerationOptions, MediaProvider};
use crate::ui;

const MAX_RETRIES: u32 = 3;
const INITIAL_BACKOFF_SECS: u64 = 2;
const GENERATE_CONTENT_MODEL: &str = "gemini-2.5-flash-image";

pub struct GeminiProvider;

#[async_trait::async_trait]
impl MediaProvider for GeminiProvider {
    async fn generate(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        if attachments.is_empty() {
            self.generate_predict(prompt_text, output_path, api_key, options)
                .await
        } else {
            self.generate_content(prompt_text, output_path, api_key, options, attachments)
                .await
        }
    }

    fn name(&self) -> &str {
        "gemini"
    }
}

impl GeminiProvider {
    /// Plain generation via the Imagen predict endpoint (no attachments).
    async fn generate_predict(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
    ) -> color_eyre::Result<bool> {
        let url = format!(
            "https://generativelanguage.googleapis.com/v1beta/models/{}:predict?key={}",
            options.model, api_key
        );

        let mut params = json!({ "sampleCount": 1 });
        if let Some(ref ar) = options.aspect_ratio {
            params["aspectRatio"] = json!(ar);
        }
        for (k, v) in &options.provider_options {
            match k.as_str() {
                "safety_filter_level" => {
                    if let Some(s) = v.as_str() {
                        params["safetyFilterLevel"] = json!(s);
                    }
                }
                "person_generation" => {
                    if let Some(s) = v.as_str() {
                        params["personGeneration"] = json!(s);
                    }
                }
                _ => {}
            }
        }

        let body = json!({
            "instances": [{ "prompt": prompt_text }],
            "parameters": params,
        });

        if options.verbose {
            ui::verbose(&format!(
                "POST {}?key=***",
                url.split('?').next().unwrap_or(&url)
            ));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Prompt: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
        }

        let result = self.post_with_retry(&url, &body, output_path, options.verbose).await?;
        let Some(result) = result else {
            return Ok(false);
        };

        let predictions = result["predictions"].as_array();
        if predictions.is_none() || predictions.unwrap().is_empty() {
            ui::fail_msg(&format!("No predictions returned for {}", output_path.display()));
            return Ok(false);
        }

        let image_b64 = predictions.unwrap()[0]["bytesBase64Encoded"]
            .as_str()
            .unwrap_or("");
        if image_b64.is_empty() {
            ui::fail_msg(&format!("Empty image data for {}", output_path.display()));
            return Ok(false);
        }

        let image_bytes = base64::engine::general_purpose::STANDARD.decode(image_b64)?;
        if let Some(parent) = output_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::write(output_path, &image_bytes)?;
        Ok(true)
    }

    /// Generation with reference images via the generateContent endpoint.
    async fn generate_content(
        &self,
        prompt_text: &str,
        output_path: &Path,
        api_key: &str,
        options: &GenerationOptions,
        attachments: &[LoadedAttachment],
    ) -> color_eyre::Result<bool> {
        let model = options
            .provider_options
            .get("generate_content_model")
            .and_then(|v| v.as_str())
            .unwrap_or(GENERATE_CONTENT_MODEL);

        let url = format!(
            "https://generativelanguage.googleapis.com/v1beta/models/{}:generateContent?key={}",
            model, api_key
        );

        let mut parts: Vec<serde_json::Value> = Vec::new();

        // Text prompt first
        parts.push(json!({ "text": prompt_text }));

        // Attachment images as inline_data parts
        for att in attachments {
            parts.push(json!({
                "inline_data": {
                    "mime_type": att.mime_type,
                    "data": att.data_b64,
                }
            }));
        }

        let body = json!({
            "contents": [{ "parts": parts }],
            "generationConfig": {
                "responseModalities": ["TEXT", "IMAGE"],
            }
        });

        if options.verbose {
            ui::verbose(&format!(
                "POST {}?key=*** (generateContent with {} attachment(s))",
                url.split('?').next().unwrap_or(&url),
                attachments.len()
            ));
            let preview: String = prompt_text.chars().take(120).collect();
            ui::verbose(&format!(
                "Prompt: {}{}",
                preview,
                if prompt_text.len() > 120 { "..." } else { "" }
            ));
            ui::verbose(&format!("Model: {} (generateContent)", model));
        }

        let result = self.post_with_retry(&url, &body, output_path, options.verbose).await?;
        let Some(result) = result else {
            return Ok(false);
        };

        // Extract image from generateContent response
        let candidates = result["candidates"].as_array();
        if candidates.is_none() || candidates.unwrap().is_empty() {
            ui::fail_msg(&format!("No candidates in response for {}", output_path.display()));
            return Ok(false);
        }

        let parts = candidates.unwrap()[0]["content"]["parts"].as_array();
        if let Some(parts) = parts {
            for part in parts {
                if let Some(inline) = part.get("inlineData").or(part.get("inline_data")) {
                    let image_b64 = inline["data"].as_str().unwrap_or("");
                    if !image_b64.is_empty() {
                        let image_bytes =
                            base64::engine::general_purpose::STANDARD.decode(image_b64)?;
                        if let Some(parent) = output_path.parent() {
                            std::fs::create_dir_all(parent)?;
                        }
                        std::fs::write(output_path, &image_bytes)?;
                        return Ok(true);
                    }
                }
            }
        }

        // If we got here, no image was found in the response
        if options.verbose {
            let resp_preview = serde_json::to_string_pretty(&result).unwrap_or_default();
            let truncated: String = resp_preview.chars().take(500).collect();
            ui::verbose(&format!("Response (no image found): {}", truncated));
        }
        ui::fail_msg(&format!("No image data in response for {}", output_path.display()));
        Ok(false)
    }

    /// Shared HTTP POST with retry/backoff logic.
    async fn post_with_retry(
        &self,
        url: &str,
        body: &serde_json::Value,
        output_path: &Path,
        verbose: bool,
    ) -> color_eyre::Result<Option<serde_json::Value>> {
        let client = reqwest::Client::new();
        let mut backoff = INITIAL_BACKOFF_SECS;

        for attempt in 1..=MAX_RETRIES {
            let resp = client
                .post(url)
                .header("Content-Type", "application/json")
                .json(body)
                .timeout(Duration::from_secs(120))
                .send()
                .await;

            match resp {
                Ok(response) => {
                    let status = response.status();
                    if status.is_success() {
                        let result: serde_json::Value = response.json().await?;
                        return Ok(Some(result));
                    }

                    let status_code = status.as_u16();
                    let error_body = response.text().await.unwrap_or_default();

                    match status_code {
                        429 if attempt < MAX_RETRIES => {
                            ui::warn_msg(&format!(
                                "Rate limited (429), retrying in {}s (attempt {}/{})",
                                backoff, attempt, MAX_RETRIES
                            ));
                            tokio::time::sleep(Duration::from_secs(backoff)).await;
                            backoff *= 2;
                            continue;
                        }
                        429 => {
                            ui::fail_msg(&format!(
                                "Rate limited after {} retries: {}",
                                MAX_RETRIES, output_path.display()
                            ));
                            return Ok(None);
                        }
                        400 => {
                            let preview: String = error_body.chars().take(300).collect();
                            ui::fail_msg(&format!(
                                "Bad request (400) for {}: {}",
                                output_path.display(), preview
                            ));
                            if verbose {
                                ui::verbose(&error_body);
                            }
                            return Ok(None);
                        }
                        401 | 403 => {
                            let preview: String = error_body.chars().take(200).collect();
                            color_eyre::eyre::bail!(
                                "Authentication failed ({}): {}\n  Check your GEMINI_API_KEY",
                                status_code, preview
                            );
                        }
                        _ => {
                            let preview: String = error_body.chars().take(200).collect();
                            ui::fail_msg(&format!(
                                "HTTP {} for {}: {}",
                                status_code, output_path.display(), preview
                            ));
                            return Ok(None);
                        }
                    }
                }
                Err(e) => {
                    ui::fail_msg(&format!("Network error for {}: {}", output_path.display(), e));
                    if attempt < MAX_RETRIES {
                        ui::warn_msg(&format!(
                            "Retrying in {}s (attempt {}/{})",
                            backoff, attempt, MAX_RETRIES
                        ));
                        tokio::time::sleep(Duration::from_secs(backoff)).await;
                        backoff *= 2;
                        continue;
                    }
                    return Ok(None);
                }
            }
        }

        Ok(None)
    }
}
