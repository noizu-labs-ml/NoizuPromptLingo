use std::time::Duration;

use serde_json::json;

use crate::schema::{AssetType, PromptSection};
use crate::ui;

const GROQ_API_URL: &str = "https://api.groq.com/openai/v1/chat/completions";
const DEFAULT_PREP_MODEL: &str = "meta-llama/llama-4-scout-17b-16e-instruct";

pub struct PreparedPrompt {
    pub text: String,
    pub negative: Option<String>,
}

pub struct PromptPrepper {
    pub base_url: String,
    pub model: String,
    pub api_key: String,
}

impl PromptPrepper {
    /// Resolve the prompt preparation LLM endpoint.
    ///
    /// Priority:
    ///   1. MEDIA_PREP_BASE_URL env / --prep-url   (OpenAI-compatible endpoint)
    ///   2. Groq cloud API (GROQ_API_KEY must be set)
    ///
    /// Model: MEDIA_PREP_MODEL env / --prep-model, else default.
    pub fn resolve(
        cli_url: Option<&str>,
        cli_model: Option<&str>,
        verbose: bool,
    ) -> Option<PromptPrepper> {
        let model = cli_model
            .map(|s| s.to_string())
            .or_else(|| std::env::var("MEDIA_PREP_MODEL").ok())
            .unwrap_or_else(|| DEFAULT_PREP_MODEL.to_string());

        // Priority 1: explicit override
        if let Some(url) = cli_url.map(|s| s.to_string()).or_else(|| std::env::var("MEDIA_PREP_BASE_URL").ok()) {
            let api_key = std::env::var("MEDIA_PREP_API_KEY").unwrap_or_else(|_| "none".into());
            if verbose {
                ui::verbose(&format!("Prompt prep via custom endpoint: {} (model: {})", url, model));
            }
            return Some(PromptPrepper { base_url: url, model, api_key });
        }

        // Priority 2: Groq cloud
        if let Ok(key) = std::env::var("GROQ_API_KEY") {
            if !key.is_empty() {
                if verbose {
                    ui::verbose(&format!("Prompt prep via Groq (model: {})", model));
                }
                return Some(PromptPrepper {
                    base_url: GROQ_API_URL.trim_end_matches("/chat/completions").to_string(),
                    model,
                    api_key: key,
                });
            }
        }

        if verbose {
            ui::verbose("No prompt prep endpoint available (set GROQ_API_KEY or MEDIA_PREP_BASE_URL)");
        }
        None
    }

    pub async fn prepare_prompt(
        &self,
        prompt_section: &PromptSection,
        service: &str,
        asset_type: AssetType,
        verbose: bool,
    ) -> Option<PreparedPrompt> {
        let system_context = prompt_section.system.as_deref().unwrap_or("");
        let raw_text = &prompt_section.text;
        let raw_negative = prompt_section.negative.as_deref().unwrap_or("");

        let provider_guidance = provider_prompt_guidance(service, asset_type);
        let limit = crate::providers::constraints(service).max_prompt_chars;
        let length_instruction = if let Some(max) = limit {
            format!(
                "\nCRITICAL LENGTH CONSTRAINT: The target provider has a {} character prompt limit. \
                 The source is {} chars. You MUST condense the output to fit within {} characters \
                 while preserving the most important creative details. Prioritize: subject description, \
                 art style, mood, key visual elements. Cut: timestamps, section headers, redundant \
                 phrasings, implementation details.\n",
                max, prompt_section.text.len(), max
            )
        } else {
            String::new()
        };

        let instruction = format!(
            r#"You are preparing a prompt for an AI image/media generator. The source is a detailed creative specification. Your job is to CLEAN it for the target provider — NOT to summarize or shorten it unless a length constraint requires it. The detailed descriptions, mood language, and specific visual directions are what make the prompt effective. Preserve them.{length_instruction}

SOURCE SPECIFICATION:
{system_section}
--- Creative Brief ---
{raw_text}

--- Negative/Exclusions ---
{raw_negative}

TARGET PROVIDER: {service}
ASSET TYPE: {asset_type:?}

{provider_guidance}

WHAT TO CHANGE:
- Merge any "Art Direction" / system context into the main prompt as a style preamble
- Replace hex color codes with descriptive color names (e.g. #C0503A → warm muted red, #FFB347 → warm amber, #3E2723 → dark warm brown, #FFF8E1 → warm cream)
- Remove pixel dimensions, percentage values, and CSS-like specs (e.g. "80px wide", "32x32", "15% of screen space") — describe relative sizes instead ("small", "subtle", "compact")
- Remove section headers, bullet formatting, and numbered lists — flow the descriptions into natural prose paragraphs
- Remove implementation instructions ("opens on click", "slides in from edges", "transitions implied") — describe the static visual appearance only
- Remove font specifications — describe the feel instead ("warm hand-lettered style", "clean readable numerals")
- Keep ALL descriptive content: colors, materials, textures, spatial arrangement, mood language, style references, specific named elements, quantities/values shown in UI
- Keep the overall length similar to the original — do NOT compress into a short summary
- The negative prompt should pass through with minimal changes (just clean formatting)

Reply with ONLY valid JSON (no markdown fences, no commentary):
{{"prompt": "the cleaned prompt text", "negative": "cleaned negative prompt or empty string"}}"#,
            system_section = if system_context.is_empty() {
                String::new()
            } else {
                format!("--- Art Direction ---\n{}\n", system_context)
            },
        );

        let url = if self.base_url.ends_with("/chat/completions") {
            self.base_url.clone()
        } else {
            format!("{}/chat/completions", self.base_url)
        };

        let body = json!({
            "model": self.model,
            "messages": [{"role": "user", "content": instruction}],
            "temperature": 0.3,
            "max_tokens": 2048,
        });

        let client = reqwest::Client::new();

        if verbose {
            ui::verbose(&format!("Prompt prep POST {} (service={}, model={})", url, service, self.model));
        }

        let resp = match client
            .post(&url)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(60))
            .send()
            .await
        {
            Ok(r) => r,
            Err(e) => {
                if verbose {
                    ui::verbose(&format!("Prompt prep request failed: {}", e));
                }
                return None;
            }
        };

        if !resp.status().is_success() {
            let status = resp.status();
            let body_text = resp.text().await.unwrap_or_default();
            if verbose {
                ui::verbose(&format!("Prompt prep HTTP {}: {}", status, &body_text[..body_text.len().min(200)]));
            }
            return None;
        }

        let val: serde_json::Value = match resp.json().await {
            Ok(v) => v,
            Err(e) => {
                if verbose {
                    ui::verbose(&format!("Prompt prep response parse error: {}", e));
                }
                return None;
            }
        };

        let raw = val["choices"][0]["message"]["content"]
            .as_str()
            .unwrap_or("")
            .trim()
            .to_string();

        if verbose {
            ui::verbose(&format!(
                "Prompt prep raw: {}",
                &raw[..raw.len().min(300)]
            ));
        }

        let cleaned = strip_reasoning_and_fences(&raw);

        match serde_json::from_str::<serde_json::Value>(&cleaned) {
            Ok(parsed) => {
                let text = parsed["prompt"].as_str().unwrap_or("").trim().to_string();
                if text.is_empty() {
                    if verbose {
                        ui::verbose("Prompt prep returned empty prompt — falling back to raw");
                    }
                    return None;
                }
                let negative = parsed["negative"]
                    .as_str()
                    .map(|s| s.trim().to_string())
                    .filter(|s| !s.is_empty());

                // Enforce hard limit if the LLM still exceeded it
                let text = if let Some(max) = limit {
                    if text.len() > max {
                        if verbose {
                            ui::verbose(&format!(
                                "LLM output ({} chars) still exceeds limit ({}) — trimming at sentence boundary",
                                text.len(), max
                            ));
                        }
                        truncate_at_sentence(&text, max)
                    } else {
                        text
                    }
                } else {
                    text
                };

                Some(PreparedPrompt { text, negative })
            }
            Err(e) => {
                if verbose {
                    ui::verbose(&format!("Prompt prep JSON parse failed: {} — cleaned text: {}", e, &cleaned[..cleaned.len().min(200)]));
                }
                None
            }
        }
    }

    /// Refine a prompt based on eval feedback and the actual failed output.
    /// The LLM sees the generated image alongside the eval scores/notes so it
    /// can make targeted corrections based on what the model actually produced.
    pub async fn refine_prompt(
        &self,
        prompt_section: &PromptSection,
        service: &str,
        asset_type: AssetType,
        eval_notes: &str,
        scores_summary: &str,
        failed_output: Option<&std::path::Path>,
        verbose: bool,
    ) -> Option<PreparedPrompt> {
        let system_context = prompt_section.system.as_deref().unwrap_or("");
        let raw_text = &prompt_section.text;
        let raw_negative = prompt_section.negative.as_deref().unwrap_or("");

        let provider_guidance = provider_prompt_guidance(service, asset_type);

        let instruction = format!(
            r#"You are refining a generation prompt that failed quality evaluation. The original specification is rich and detailed — your job is to adjust the prompt to fix the specific issues the evaluator identified, NOT to rewrite from scratch.

ORIGINAL SPECIFICATION:
{system_section}
--- Creative Brief ---
{raw_text}

--- Negative/Exclusions ---
{raw_negative}

TARGET PROVIDER: {service}
ASSET TYPE: {asset_type:?}

EVALUATION FEEDBACK (why the previous generation failed):
Scores: {scores_summary}
Notes: {eval_notes}

{provider_guidance}

REFINEMENT RULES:
- Start from the full original description — do NOT summarize or shorten
- Make targeted adjustments to address the eval feedback:
  - Low anatomy/proportion scores → add explicit proportion/anatomy guidance ("correct human proportions", "anatomically accurate hands")
  - Low style scores → reinforce style terms more prominently at the start
  - Low composition scores → strengthen spatial arrangement descriptions
  - Low prompt_fidelity → ensure missing elements are described more prominently
  - Reject hits → add explicit exclusions to the negative prompt
  - Text rendering issues → describe text content differently, or add "no visible text" if labels aren't needed
- Keep descriptive richness — the detailed language is what makes the prompt effective
- Replace hex codes with color names, remove pixel dimensions (same cleanup as initial prep)

Reply with ONLY valid JSON (no markdown fences, no commentary):
{{"prompt": "the refined prompt text", "negative": "refined negative prompt or empty string"}}"#,
            system_section = if system_context.is_empty() {
                String::new()
            } else {
                format!("--- Art Direction ---\n{}\n", system_context)
            },
        );

        let url = if self.base_url.ends_with("/chat/completions") {
            self.base_url.clone()
        } else {
            format!("{}/chat/completions", self.base_url)
        };

        // Build message content — text instruction + optional failed output image
        let content = if let Some(output_path) = failed_output {
            let ext = output_path.extension().and_then(|e| e.to_str()).unwrap_or("");
            match ext {
                "png" | "jpg" | "jpeg" | "webp" => {
                    if let Ok(data) = std::fs::read(output_path) {
                        use base64::Engine;
                        let b64 = base64::engine::general_purpose::STANDARD.encode(&data);
                        let mime = match ext {
                            "png" => "image/png",
                            "jpg" | "jpeg" => "image/jpeg",
                            "webp" => "image/webp",
                            _ => "image/png",
                        };
                        if verbose {
                            ui::verbose("Including failed output image in refinement request");
                        }
                        json!([
                            {"type": "text", "text": instruction},
                            {"type": "text", "text": "\n\n[The image below is what the previous generation produced — use it to understand what went wrong and what to fix in the prompt]"},
                            {"type": "image_url", "image_url": {"url": format!("data:{};base64,{}", mime, b64)}}
                        ])
                    } else {
                        json!(instruction)
                    }
                }
                // Text-based outputs (SVG, HTML, etc.) — include inline
                "svg" | "html" | "mmd" | "tsx" | "md" => {
                    if let Ok(text_content) = std::fs::read_to_string(output_path) {
                        let truncated = if text_content.len() > 8192 { &text_content[..8192] } else { &text_content };
                        json!(format!("{}\n\n[Previous output content]\n{}", instruction, truncated))
                    } else {
                        json!(instruction)
                    }
                }
                _ => json!(instruction),
            }
        } else {
            json!(instruction)
        };

        let body = json!({
            "model": self.model,
            "messages": [{"role": "user", "content": content}],
            "temperature": 0.4,
            "max_tokens": 2048,
        });

        let client = reqwest::Client::new();

        if verbose {
            ui::verbose(&format!("Prompt refine POST {} (vision-informed refinement)", url));
        }

        let resp = match client
            .post(&url)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .header("Content-Type", "application/json")
            .json(&body)
            .timeout(Duration::from_secs(60))
            .send()
            .await
        {
            Ok(r) => r,
            Err(e) => {
                if verbose {
                    ui::verbose(&format!("Prompt refine request failed: {}", e));
                }
                return None;
            }
        };

        if !resp.status().is_success() {
            if verbose {
                ui::verbose(&format!("Prompt refine HTTP {}", resp.status()));
            }
            return None;
        }

        let val: serde_json::Value = match resp.json().await {
            Ok(v) => v,
            Err(e) => {
                if verbose {
                    ui::verbose(&format!("Prompt refine response error: {}", e));
                }
                return None;
            }
        };

        let raw = val["choices"][0]["message"]["content"]
            .as_str()
            .unwrap_or("")
            .trim()
            .to_string();

        if verbose {
            ui::verbose(&format!("Prompt refine raw: {}", &raw[..raw.len().min(300)]));
        }

        let cleaned = strip_reasoning_and_fences(&raw);

        match serde_json::from_str::<serde_json::Value>(&cleaned) {
            Ok(parsed) => {
                let text = parsed["prompt"].as_str().unwrap_or("").trim().to_string();
                if text.is_empty() {
                    return None;
                }
                let negative = parsed["negative"]
                    .as_str()
                    .map(|s| s.trim().to_string())
                    .filter(|s| !s.is_empty());
                Some(PreparedPrompt { text, negative })
            }
            Err(_) => None,
        }
    }
}

fn provider_prompt_guidance(service: &str, asset_type: AssetType) -> &'static str {
    match (service, asset_type) {
        ("gemini", AssetType::Image) => {
            "PROVIDER NOTES (Gemini Imagen):\n\
             - Imagen handles rich, detailed prompts well — do NOT shorten or summarize\n\
             - Front-load the subject and art style in the first sentence\n\
             - Art style terms are powerful: \"concept art\", \"painterly\", \"chiaroscuro\", \"oil painting\"\n\
             - Describe colors by name, never hex codes — the model renders codes as literal text\n\
             - Spatial descriptions (\"upper left\", \"in the background\") work well — keep them\n\
             - Mood and atmosphere language is highly effective — preserve all of it\n\
             - Named elements with specific quantities (\"three candles\", \"1,247 credits\") render well"
        }
        ("veo", AssetType::Video) | ("grok-video", AssetType::Video) => {
            "PROVIDER NOTES (Video generation):\n\
             - Video models need tighter prompts than image — aim for 60-120 words\n\
             - Lead with the scene, then action, then camera movement\n\
             - Art style in the first sentence\n\
             - Remove static layout details — describe motion and temporal flow"
        }
        ("suno", AssetType::Audio) => {
            "PROVIDER NOTES (Suno music generation):\n\
             - Lead with genre and mood\n\
             - List instruments and describe the overall sound\n\
             - Describe structure as phases (intro/build/climax/outro), not exact timestamps\n\
             - Keep under 200 words — Suno works best with focused descriptions\n\
             - Remove bar-by-bar breakdowns but keep emotional arc descriptions"
        }
        ("elevenlabs" | "openai-tts" | "qwen-tts", AssetType::Audio) => {
            "PROVIDER NOTES (TTS/Voice):\n\
             - Return the speaking text VERBATIM — do not rewrite\n\
             - Only clean formatting (remove bullets, headers)\n\
             - Voice style direction belongs in provider_options, not the prompt"
        }
        (_, AssetType::Image) => {
            "PROVIDER NOTES (Image generation):\n\
             - Detailed prompts work well — do NOT shorten or summarize\n\
             - Front-load subject and art style\n\
             - Replace hex codes with color names, remove pixel dimensions\n\
             - Keep all descriptive and mood language"
        }
        _ => {
            "PROVIDER NOTES:\n\
             - Clean technical tokens but preserve descriptive content\n\
             - Remove formatting artifacts (bullets, headers) — flow into prose"
        }
    }
}

fn strip_reasoning_and_fences(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut rest = s;
    loop {
        match rest.find("<think>") {
            Some(start) => {
                out.push_str(&rest[..start]);
                match rest[start..].find("</think>") {
                    Some(end_rel) => {
                        rest = &rest[start + end_rel + "</think>".len()..];
                    }
                    None => break,
                }
            }
            None => {
                out.push_str(rest);
                break;
            }
        }
    }
    // Sanitize control characters inside JSON string values.
    // LLMs often emit literal newlines/tabs inside JSON strings;
    // replace them with spaces so serde_json can parse.
    let mut sanitized = String::with_capacity(out.len());
    let mut in_string = false;
    let mut prev_backslash = false;
    for ch in out.chars() {
        if in_string {
            if prev_backslash {
                prev_backslash = false;
                sanitized.push(ch);
                continue;
            }
            if ch == '\\' {
                prev_backslash = true;
                sanitized.push(ch);
                continue;
            }
            if ch == '"' {
                in_string = false;
                sanitized.push(ch);
                continue;
            }
            if ch.is_control() {
                sanitized.push(' ');
                continue;
            }
            sanitized.push(ch);
        } else {
            if ch == '"' {
                in_string = true;
            }
            sanitized.push(ch);
        }
    }

    let trimmed = sanitized.trim();
    if trimmed.starts_with("```") {
        let after_fence = if let Some(nl) = trimmed.find('\n') {
            &trimmed[nl + 1..]
        } else {
            trimmed
        };
        return after_fence.trim_end_matches("```").trim_end().to_string();
    }
    trimmed.to_string()
}

fn truncate_at_sentence(text: &str, max: usize) -> String {
    if text.len() <= max {
        return text.to_string();
    }
    let cut = &text[..max];
    // Find the last sentence-ending punctuation
    if let Some(pos) = cut.rfind(|c: char| c == '.' || c == '!' || c == '?') {
        cut[..=pos].trim().to_string()
    } else if let Some(pos) = cut.rfind(',') {
        cut[..pos].trim().to_string()
    } else {
        cut.trim().to_string()
    }
}
