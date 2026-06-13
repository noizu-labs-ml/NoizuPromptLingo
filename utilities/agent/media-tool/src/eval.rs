use std::collections::HashMap;
use std::path::Path;
use std::time::Duration;

use base64::Engine;
use serde_json::json;

use crate::attachments::resolve_mime_type;
use crate::schema::{EvalCriterion, EvalSection};
use crate::ui;

// ---------------------------------------------------------------------------
// Groq last-resort variant selection (kept as fallback)
// ---------------------------------------------------------------------------

const GROQ_API_URL: &str = "https://api.groq.com/openai/v1/chat/completions";
const DEFAULT_GROQ_MODEL: &str = "meta-llama/llama-4-scout-17b-16e-instruct";

pub async fn evaluate_candidates(
    candidate_paths: &[&Path],
    prompt_text: &str,
    eval_criteria: Option<&HashMap<String, EvalCriterion>>,
    api_key: &str,
    model: Option<&str>,
    verbose: bool,
) -> usize {
    if candidate_paths.len() <= 1 {
        return 0;
    }

    if api_key.is_empty() {
        ui::warn_msg("No GROQ_API_KEY \u{2014} selecting first candidate");
        return 0;
    }

    let model = model.unwrap_or(DEFAULT_GROQ_MODEL);
    let mut content_parts: Vec<serde_json::Value> = Vec::new();

    let mut criteria_text = String::new();
    if let Some(criteria) = eval_criteria {
        criteria_text.push_str("\nEvaluation criteria:\n");
        for (name, spec) in criteria {
            let desc = spec.description.as_deref().unwrap_or(name);
            let weight = spec.weight.map(|w| format!("{}", w)).unwrap_or_default();
            criteria_text.push_str(&format!("  - {} (weight {}): {}\n", name, weight, desc));
        }
    }

    content_parts.push(json!({
        "type": "text",
        "text": format!(
            "You are evaluating {} AI-generated images.\n\
             The generation prompt was:\n\"{}\"\n\
             {}\n\n\
             Each image is labelled [Image 1], [Image 2], etc.\n\
             Pick the single best image. Reply with ONLY the number (e.g. 2).",
            candidate_paths.len(),
            prompt_text,
            criteria_text
        )
    }));

    for (i, cpath) in candidate_paths.iter().enumerate() {
        let mime = resolve_mime_type(cpath, None);
        let data = match std::fs::read(cpath) {
            Ok(d) => d,
            Err(e) => {
                ui::warn_msg(&format!("Cannot read candidate {}: {}", cpath.display(), e));
                continue;
            }
        };
        let b64 = base64::engine::general_purpose::STANDARD.encode(&data);

        content_parts.push(json!({
            "type": "image_url",
            "image_url": { "url": format!("data:{};base64,{}", mime, b64) }
        }));
        content_parts.push(json!({
            "type": "text",
            "text": format!("[Image {}]", i + 1)
        }));
    }

    let body = json!({
        "model": model,
        "messages": [{ "role": "user", "content": content_parts }],
        "temperature": 0,
        "max_tokens": 16,
    });

    if verbose {
        ui::verbose(&format!(
            "Groq vision eval: {} candidates via {}",
            candidate_paths.len(),
            model
        ));
    }

    let client = reqwest::Client::new();
    let result = client
        .post(GROQ_API_URL)
        .header("Content-Type", "application/json")
        .header("Authorization", format!("Bearer {}", api_key))
        .json(&body)
        .timeout(Duration::from_secs(120))
        .send()
        .await;

    match result {
        Ok(resp) if resp.status().is_success() => {
            if let Ok(val) = resp.json::<serde_json::Value>().await {
                if let Some(text) = val["choices"][0]["message"]["content"].as_str() {
                    let text = strip_think(text);
                    let text = text.trim();
                    if verbose {
                        ui::verbose(&format!("Groq response: {:?}", text));
                    }
                    if let Ok(num) = text
                        .chars()
                        .filter(|c| c.is_ascii_digit())
                        .collect::<String>()
                        .parse::<usize>()
                    {
                        let idx = num.saturating_sub(1);
                        if idx < candidate_paths.len() {
                            return idx;
                        }
                    }
                    ui::warn_msg(&format!(
                        "Could not parse Groq selection ({:?}) \u{2014} defaulting to first",
                        text
                    ));
                }
            }
            0
        }
        Ok(resp) => {
            ui::warn_msg(&format!(
                "Groq vision eval failed (HTTP {}) \u{2014} selecting first candidate",
                resp.status()
            ));
            0
        }
        Err(e) => {
            ui::warn_msg(&format!(
                "Groq vision eval failed: {} \u{2014} selecting first candidate",
                e
            ));
            0
        }
    }
}

// ---------------------------------------------------------------------------
// EvalScore
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct EvalScore {
    pub weighted: f64,
    pub per_criterion: HashMap<String, f64>,
    pub reject_hits: Vec<String>,
    pub notes: String,
}

impl EvalScore {
    /// True if this score constitutes a pass against the eval section's thresholds.
    pub fn passes(&self, eval: &EvalSection) -> bool {
        let threshold = eval.effective_pass_threshold();

        // Global weighted score
        if self.weighted < threshold {
            return false;
        }

        // All required_pass criteria must individually reach threshold
        for key in &eval.required_pass {
            let score = self.per_criterion.get(key).copied().unwrap_or(0.0);
            if score < threshold {
                return false;
            }
        }

        // No reject_if hits allowed
        if !self.reject_hits.is_empty() {
            return false;
        }

        true
    }
}

// ---------------------------------------------------------------------------
// Evaluator
// ---------------------------------------------------------------------------

pub struct Evaluator {
    pub base_url: String,
    pub model: String,
    pub api_key: String,
}

impl Evaluator {
    /// Probe the candidate endpoints (env/CLI override, LAN Qwen host, in-cluster
    /// DNS, local forward) and return the first reachable one.
    /// Model is auto-discovered if not overridden.
    pub async fn resolve(
        cli_url: Option<&str>,
        cli_model: Option<&str>,
        verbose: bool,
    ) -> Option<Evaluator> {
        let override_url = cli_url
            .map(|s| s.to_string())
            .or_else(|| std::env::var("MEDIA_EVAL_BASE_URL").ok());

        let api_key = std::env::var("MEDIA_EVAL_API_KEY").unwrap_or_else(|_| "lm-studio".into());

        // Build candidate list. Groq is tried first when GROQ_API_KEY is set
        // (fast, cloud-hosted, vision-capable via Llama 4 Scout).
        let groq_key = std::env::var("GROQ_API_KEY").ok().filter(|k| !k.is_empty());

        let candidates: Vec<(String, Option<String>)> = if let Some(url) = override_url {
            vec![(url, None)]
        } else {
            let mut c: Vec<(String, Option<String>)> = Vec::new();
            // Groq cloud (vision-capable, fast)
            if let Some(ref key) = groq_key {
                c.push(("https://api.groq.com/openai/v1".into(), Some(key.clone())));
            }
            // LAN server hosting Qwen 3.6
            c.push(("http://192.168.68.59:3713/v1".into(), None));
            // noizu.server forward
            c.push(("http://noizu.server:3713/v1".into(), None));
            // in-cluster service DNS
            c.push(("http://lmstudio-proxy:3713/v1".into(), None));
            // local forward
            c.push(("http://127.0.0.1:3713/v1".into(), None));
            c
        };

        let client = reqwest::Client::new();

        for (base, override_key) in &candidates {
            let effective_key = override_key.as_deref().unwrap_or(&api_key);
            let models_url = format!("{}/models", base);
            if verbose {
                ui::verbose(&format!("Probing eval endpoint: {}", base));
            }
            match client
                .get(&models_url)
                .header("Authorization", format!("Bearer {}", effective_key))
                .timeout(Duration::from_secs(2))
                .send()
                .await
            {
                Ok(resp) if resp.status().is_success() => {
                    // Determine model
                    let model_id = if let Some(m) = cli_model {
                        m.to_string()
                    } else if let Ok(env_m) = std::env::var("MEDIA_EVAL_MODEL") {
                        env_m
                    } else {
                        // Auto-discover from response
                        let models_json = resp.json::<serde_json::Value>().await.unwrap_or_default();
                        pick_model(&models_json, verbose)
                    };

                    if verbose {
                        ui::verbose(&format!(
                            "Eval endpoint reachable: {} (model: {})",
                            base, model_id
                        ));
                    }

                    return Some(Evaluator {
                        base_url: base.clone(),
                        model: model_id,
                        api_key: effective_key.to_string(),
                    });
                }
                Ok(resp) => {
                    if verbose {
                        ui::verbose(&format!(
                            "Eval probe {} returned {}",
                            base,
                            resp.status()
                        ));
                    }
                }
                Err(e) => {
                    if verbose {
                        ui::verbose(&format!("Eval probe {} unreachable: {}", base, e));
                    }
                }
            }
        }

        if verbose {
            ui::verbose("No eval endpoint reachable — grading disabled");
        }
        None
    }

    /// Score a single output artifact against the eval criteria.
    /// Returns None for un-scorable artifacts (audio, missing ffmpeg for video).
    pub async fn score_output(
        &self,
        path: &Path,
        prompt_text: &str,
        eval: &EvalSection,
        verbose: bool,
    ) -> Option<EvalScore> {
        let ext = path
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("")
            .to_lowercase();

        // Build content parts
        let content_parts = match ext.as_str() {
            // Images — base64 inline
            "png" | "jpg" | "jpeg" | "webp" => {
                let data = std::fs::read(path).ok()?;
                let b64 = base64::engine::general_purpose::STANDARD.encode(&data);
                let mime = resolve_mime_type(path, None);
                vec![json!({
                    "type": "image_url",
                    "image_url": { "url": format!("data:{};base64,{}", mime, b64) }
                })]
            }
            // Text-like files — inline (truncated at ~32 KB)
            "svg" | "mmd" | "puml" | "dot" | "html" | "tsx" | "ts" | "js" | "md" | "json"
            | "txt" | "css" => {
                let raw = std::fs::read_to_string(path).ok()?;
                const MAX_BYTES: usize = 32 * 1024;
                let truncated = if raw.len() > MAX_BYTES {
                    &raw[..MAX_BYTES]
                } else {
                    &raw
                };
                vec![json!({
                    "type": "text",
                    "text": format!("[artifact content]\n{}", truncated)
                })]
            }
            // Video — extract frames via ffmpeg
            "mp4" | "webm" | "mov" => match extract_video_frames(path, verbose).await {
                Some(frames) => frames,
                None => {
                    if verbose {
                        ui::verbose(&format!(
                            "Video {} is un-scorable (ffmpeg unavailable or failed)",
                            path.display()
                        ));
                    }
                    return None;
                }
            },
            // Audio — un-scorable
            "mp3" | "wav" | "ogg" | "flac" => {
                if verbose {
                    ui::verbose(&format!(
                        "Audio {} is un-scorable — accepting without eval",
                        path.display()
                    ));
                }
                return None;
            }
            _ => {
                if verbose {
                    ui::verbose(&format!(
                        "Unknown extension '{}' for {} — un-scorable",
                        ext,
                        path.display()
                    ));
                }
                return None;
            }
        };

        self.request_score(content_parts, prompt_text, eval, verbose).await
    }

    async fn request_score(
        &self,
        mut content_parts: Vec<serde_json::Value>,
        prompt_text: &str,
        eval: &EvalSection,
        verbose: bool,
    ) -> Option<EvalScore> {
        // Build criteria description
        let mut criteria_list = String::new();
        let criterion_names: Vec<&str> = eval.criteria.keys().map(|s| s.as_str()).collect();
        for (name, spec) in &eval.criteria {
            let desc = spec.description.as_deref().unwrap_or(name);
            let weight = spec.weight.unwrap_or(1.0);
            let signals = if spec.fail_signals.is_empty() {
                String::new()
            } else {
                format!(" [fail signals: {}]", spec.fail_signals.join(", "))
            };
            criteria_list.push_str(&format!(
                "  - {}: {} (weight {:.1}){}\n",
                name, desc, weight, signals
            ));
        }

        let reject_list = if eval.reject_if.is_empty() {
            String::new()
        } else {
            format!(
                "\nReject if any of these are visible:\n{}\n",
                eval.reject_if.iter().map(|r| format!("  - {}", r)).collect::<Vec<_>>().join("\n")
            )
        };

        // Prepend instruction text
        let instruction = json!({
            "type": "text",
            "text": format!(
                "Grade this generated artifact against the following criteria.\n\
                 Generation prompt: \"{}\"\n\n\
                 Criteria (score each 0-10):\n\
                 {}\
                 {}\n\
                 Reply ONLY with valid JSON (no markdown, no fences):\n\
                 {{\"scores\": {{{}}}, \"reject_hits\": [\"...\"], \"notes\": \"...\"}}",
                prompt_text,
                criteria_list,
                reject_list,
                criterion_names.iter().map(|n| format!("\"{}\": 0-10", n)).collect::<Vec<_>>().join(", ")
            )
        });
        content_parts.insert(0, instruction);

        // Generous max_tokens: hosted reasoning models emit a long thinking phase
        // before the JSON answer — don't let it truncate.
        let body = json!({
            "model": self.model,
            "messages": [{ "role": "user", "content": content_parts }],
            "temperature": 0,
            "max_tokens": 4096,
        });

        let client = reqwest::Client::new();
        let url = format!("{}/chat/completions", self.base_url);

        if verbose {
            ui::verbose(&format!("Eval POST {}", url));
        }

        for attempt in 0..2 {
            let resp = match client
                .post(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .header("Content-Type", "application/json")
                .json(&body)
                .timeout(eval_request_timeout())
                .send()
                .await
            {
                Ok(r) => r,
                Err(e) => {
                    if verbose {
                        ui::verbose(&format!("Eval request failed: {}", e));
                    }
                    return None;
                }
            };

            if !resp.status().is_success() {
                if verbose {
                    ui::verbose(&format!("Eval returned HTTP {}", resp.status()));
                }
                return None;
            }

            let val: serde_json::Value = match resp.json().await {
                Ok(v) => v,
                Err(e) => {
                    if verbose {
                        ui::verbose(&format!("Eval response JSON error: {}", e));
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
                ui::verbose(&format!("Eval raw response: {}", &raw[..raw.len().min(400)]));
            }

            // Strip reasoning output and markdown code fences defensively
            let cleaned = strip_fences(&strip_think(&raw));

            match serde_json::from_str::<serde_json::Value>(&cleaned) {
                Ok(parsed) => {
                    return build_score(&parsed, eval, verbose);
                }
                Err(e) => {
                    if attempt == 0 {
                        if verbose {
                            ui::verbose(&format!(
                                "Eval JSON parse failed (attempt {}): {} — retrying",
                                attempt + 1,
                                e
                            ));
                        }
                        continue;
                    }
                    if verbose {
                        ui::verbose(&format!("Eval JSON parse failed after retry: {}", e));
                    }
                    return None;
                }
            }
        }

        None
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn pick_model(models_json: &serde_json::Value, verbose: bool) -> String {
    let data = match models_json["data"].as_array() {
        Some(arr) => arr,
        None => return "qwen3.6".into(),
    };

    // Filter out embedding models
    let non_embedding: Vec<&str> = data
        .iter()
        .filter_map(|m| m["id"].as_str())
        .filter(|id| {
            let lower = id.to_lowercase();
            !lower.contains("embed") && !lower.contains("embedding")
        })
        .collect();

    if non_embedding.is_empty() {
        if verbose {
            ui::verbose("No non-embedding models found, using 'qwen3.6'");
        }
        return "qwen3.6".into();
    }

    // Prefer vision-capable models for eval scoring:
    // 1. Llama 4 Scout (Groq's vision model)
    if let Some(id) = non_embedding.iter().find(|id| {
        let lower = id.to_lowercase();
        lower.contains("llama-4-scout") || lower.contains("llama4-scout")
    }) {
        return id.to_string();
    }
    // 2. Any Llama 4 vision model
    if let Some(id) = non_embedding.iter().find(|id| {
        let lower = id.to_lowercase();
        lower.contains("llama-4") && !lower.contains("guard")
    }) {
        return id.to_string();
    }
    // 3. Qwen 3.6 (local LAN server)
    if let Some(id) = non_embedding.iter().find(|id| {
        let lower = id.to_lowercase();
        lower.contains("qwen3.6") || lower.contains("qwen-3.6") || lower.contains("qwen3-6")
    }) {
        return id.to_string();
    }
    if let Some(id) = non_embedding.iter().find(|id| id.to_lowercase().contains("qwen")) {
        return id.to_string();
    }

    // Fallback: first non-embedding
    non_embedding[0].to_string()
}

/// Scoring/selection chat-completion timeout: 300s default, overridable via
/// MEDIA_EVAL_TIMEOUT (seconds). The hosted Qwen 3.6 is a reasoning model and
/// can take minutes per completion.
fn eval_request_timeout() -> Duration {
    let secs = std::env::var("MEDIA_EVAL_TIMEOUT")
        .ok()
        .and_then(|v| v.trim().parse::<u64>().ok())
        .unwrap_or(300);
    Duration::from_secs(secs)
}

/// Strip a reasoning model's <think>...</think> block(s) from the response.
/// Handles an unterminated <think> (truncated thinking) by dropping everything
/// from the opening tag onward.
fn strip_think(s: &str) -> String {
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
                    None => break, // unterminated — drop the tail
                }
            }
            None => {
                out.push_str(rest);
                break;
            }
        }
    }
    out.trim().to_string()
}

fn strip_fences(s: &str) -> String {
    let s = s.trim();
    if s.starts_with("```") {
        let after_fence = if let Some(nl) = s.find('\n') {
            &s[nl + 1..]
        } else {
            s
        };
        let trimmed = after_fence.trim_end_matches("```").trim_end();
        return trimmed.to_string();
    }
    s.to_string()
}

fn build_score(
    parsed: &serde_json::Value,
    eval: &EvalSection,
    verbose: bool,
) -> Option<EvalScore> {
    let scores_map = parsed["scores"].as_object()?;

    let mut weighted_sum = 0.0f64;
    let mut weight_total = 0.0f64;
    let mut per_criterion: HashMap<String, f64> = HashMap::new();

    for (name, criterion) in &eval.criteria {
        let raw_score = scores_map
            .get(name)
            .and_then(|v| v.as_f64())
            .unwrap_or(0.0);
        // Normalize 0-10 → 0-1
        let normalized = (raw_score / 10.0).clamp(0.0, 1.0);
        let weight = criterion.weight.unwrap_or(1.0);
        weighted_sum += weight * normalized;
        weight_total += weight;
        per_criterion.insert(name.clone(), normalized);
    }

    let weighted = if weight_total > 0.0 {
        weighted_sum / weight_total
    } else {
        0.0
    };

    // Collect reject hits
    let reject_hits: Vec<String> = parsed["reject_hits"]
        .as_array()
        .map(|arr| {
            arr.iter()
                .filter_map(|v| v.as_str())
                .map(|s| s.to_string())
                .collect()
        })
        .unwrap_or_default();

    let notes = parsed["notes"]
        .as_str()
        .unwrap_or("")
        .to_string();

    if verbose {
        ui::verbose(&format!(
            "Eval score: weighted={:.3}, reject_hits={:?}, notes={}",
            weighted, reject_hits, &notes[..notes.len().min(120)]
        ));
    }

    Some(EvalScore {
        weighted,
        per_criterion,
        reject_hits,
        notes,
    })
}

/// Extract up to 4 evenly-spaced frames from a video file using ffmpeg.
/// Returns content parts (image_url entries) or None if ffmpeg is unavailable.
async fn extract_video_frames(
    path: &Path,
    verbose: bool,
) -> Option<Vec<serde_json::Value>> {
    // Check ffmpeg is on PATH
    let ffprobe_check = tokio::process::Command::new("ffprobe")
        .arg("-version")
        .output()
        .await;
    if ffprobe_check.is_err() {
        if verbose {
            ui::verbose("ffprobe not found — video eval skipped");
        }
        return None;
    }

    // Get video duration via ffprobe
    let duration_output = tokio::process::Command::new("ffprobe")
        .args([
            "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            path.to_str()?,
        ])
        .output()
        .await
        .ok()?;

    let duration_secs: f64 = String::from_utf8_lossy(&duration_output.stdout)
        .trim()
        .parse()
        .unwrap_or(10.0);

    // Create temp dir for frames
    let temp_dir = std::env::temp_dir().join(format!(
        "media_eval_frames_{}",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_millis()
    ));
    std::fs::create_dir_all(&temp_dir).ok()?;

    const NUM_FRAMES: usize = 4;
    let mut parts: Vec<serde_json::Value> = Vec::new();

    for i in 0..NUM_FRAMES {
        let t = if NUM_FRAMES <= 1 {
            duration_secs / 2.0
        } else {
            duration_secs * (i as f64 + 1.0) / (NUM_FRAMES as f64 + 1.0)
        };

        let frame_path = temp_dir.join(format!("frame_{:02}.png", i));

        let result = tokio::process::Command::new("ffmpeg")
            .args([
                "-ss", &format!("{:.2}", t),
                "-i", path.to_str()?,
                "-vframes", "1",
                "-q:v", "2",
                frame_path.to_str()?,
                "-y",
            ])
            .output()
            .await;

        if let Ok(out) = result {
            if out.status.success() {
                if let Ok(data) = std::fs::read(&frame_path) {
                    let b64 = base64::engine::general_purpose::STANDARD.encode(&data);
                    parts.push(json!({
                        "type": "image_url",
                        "image_url": { "url": format!("data:image/png;base64,{}", b64) }
                    }));
                    parts.push(json!({
                        "type": "text",
                        "text": format!("[Frame at {:.1}s]", t)
                    }));
                }
            } else if verbose {
                ui::verbose(&format!("ffmpeg frame extract failed at {:.1}s", t));
            }
        }
    }

    // Cleanup temp dir (best-effort)
    let _ = std::fs::remove_dir_all(&temp_dir);

    if parts.is_empty() {
        None
    } else {
        Some(parts)
    }
}
