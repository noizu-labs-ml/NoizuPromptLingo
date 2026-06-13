use std::thread;
use std::time::Duration;

use reqwest::blocking::Client;
use serde_json::{json, Value};

use super::prompt::build_system_prompt;
use super::types::{Ticket, TicketType};

const MAX_RETRIES: u32 = 3;

pub struct LlmClient {
    client: Client,
    api_url: String,
    api_key: String,
}

impl LlmClient {
    pub fn new(api_url: &str, api_key: &str) -> Self {
        Self {
            client: Client::new(),
            api_url: api_url.to_string(),
            api_key: api_key.to_string(),
        }
    }

    /// Transcribe audio data via the OpenAI-compatible /audio/transcriptions endpoint.
    pub fn transcribe(&self, audio_data: &[u8], model: &str) -> Result<String, String> {
        let url = format!("{}/audio/transcriptions", self.api_url);

        for attempt in 0..MAX_RETRIES {
            let file_part = reqwest::blocking::multipart::Part::bytes(audio_data.to_vec())
                .file_name("recording.wav")
                .mime_str("audio/wav")
                .map_err(|e| format!("Failed to build multipart part: {e}"))?;

            let form = reqwest::blocking::multipart::Form::new()
                .text("model", model.to_string())
                .part("file", file_part);

            let result = self
                .client
                .post(&url)
                .bearer_auth(&self.api_key)
                .multipart(form)
                .send();

            match result {
                Ok(resp) => {
                    let status = resp.status();
                    let body = resp.text().unwrap_or_default();

                    if status.is_success() {
                        // Response may be JSON with a "text" field, or plain text.
                        if let Ok(v) = serde_json::from_str::<Value>(&body) {
                            if let Some(text) = v.get("text").and_then(|t| t.as_str()) {
                                return Ok(text.to_string());
                            }
                        }
                        return Ok(body);
                    }

                    if attempt < MAX_RETRIES - 1 {
                        let backoff = Duration::from_millis(500 * 2u64.pow(attempt));
                        thread::sleep(backoff);
                        continue;
                    }
                    return Err(format!("Transcription failed (HTTP {status}): {body}"));
                }
                Err(e) => {
                    if attempt < MAX_RETRIES - 1 {
                        let backoff = Duration::from_millis(500 * 2u64.pow(attempt));
                        thread::sleep(backoff);
                        continue;
                    }
                    return Err(format!("Transcription request error: {e}"));
                }
            }
        }

        Err("Transcription failed after retries".to_string())
    }

    /// Generate a structured ticket from a transcript via chat completions.
    pub fn generate_ticket(
        &self,
        transcript: &str,
        model: &str,
        type_override: Option<&TicketType>,
    ) -> Result<Ticket, String> {
        let url = format!("{}/chat/completions", self.api_url);
        let system_prompt = build_system_prompt(type_override);

        let payload = json!({
            "model": model,
            "response_format": { "type": "json_object" },
            "messages": [
                { "role": "system", "content": system_prompt },
                { "role": "user", "content": transcript },
            ],
        });

        for attempt in 0..MAX_RETRIES {
            let result = self
                .client
                .post(&url)
                .bearer_auth(&self.api_key)
                .header("Content-Type", "application/json")
                .json(&payload)
                .send();

            match result {
                Ok(resp) => {
                    let status = resp.status();
                    let body = resp.text().unwrap_or_default();

                    if !status.is_success() {
                        if attempt < MAX_RETRIES - 1 {
                            let backoff = Duration::from_millis(500 * 2u64.pow(attempt));
                            thread::sleep(backoff);
                            continue;
                        }
                        return Err(format!(
                            "Ticket generation failed (HTTP {status}): {body}"
                        ));
                    }

                    // Parse the outer chat-completions envelope.
                    let envelope: Value = serde_json::from_str(&body)
                        .map_err(|e| format!("Failed to parse completion response: {e}"))?;

                    let content = envelope
                        .pointer("/choices/0/message/content")
                        .and_then(|v| v.as_str())
                        .ok_or_else(|| {
                            "Missing choices[0].message.content in response".to_string()
                        })?;

                    // Parse the inner JSON produced by the model.
                    let ticket: Ticket = serde_json::from_str(content).map_err(|e| {
                        format!("Failed to parse ticket JSON: {e}\nRaw content: {content}")
                    })?;

                    return Ok(ticket);
                }
                Err(e) => {
                    if attempt < MAX_RETRIES - 1 {
                        let backoff = Duration::from_millis(500 * 2u64.pow(attempt));
                        thread::sleep(backoff);
                        continue;
                    }
                    return Err(format!("Ticket generation request error: {e}"));
                }
            }
        }

        Err("Ticket generation failed after retries".to_string())
    }
}
