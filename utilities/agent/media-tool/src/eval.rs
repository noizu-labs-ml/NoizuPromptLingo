use std::collections::HashMap;
use std::path::Path;
use std::time::Duration;

use base64::Engine;
use serde_json::json;

use crate::attachments::resolve_mime_type;
use crate::schema::EvalCriterion;
use crate::ui;

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
                    let text = text.trim();
                    if verbose {
                        ui::verbose(&format!("Groq response: {:?}", text));
                    }
                    if let Some(num) = text.chars().filter(|c| c.is_ascii_digit()).collect::<String>().parse::<usize>().ok() {
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
