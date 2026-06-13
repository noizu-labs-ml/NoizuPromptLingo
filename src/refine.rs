use std::path::Path;
use std::time::Duration;

use serde_json::json;

use crate::attachments::load_attachments;
use crate::output::{genai_candidate_path, link_active};
use crate::providers::{get_provider, GenerationOptions};
use crate::schema::ParsedPrompt;
use crate::ui;

const REFINE_MODEL: &str = "gemini-2.0-flash";

pub async fn interactive_refine_loop(
    prompt: &mut ParsedPrompt,
    output_paths: &[std::path::PathBuf],
    api_key: &str,
    gen_model: &str,
    verbose: bool,
) {
    let mut current_text = prompt.payload.prompt.text.clone();

    loop {
        eprint!("\n  \x1b[1;33mSatisfied? (y/n/feedback): \x1b[0m");
        let mut input = String::new();
        if std::io::stdin().read_line(&mut input).is_err() {
            ui::info("Refinement cancelled");
            return;
        }
        let input = input.trim();

        if input.is_empty() || input.eq_ignore_ascii_case("y") || input.eq_ignore_ascii_case("yes")
        {
            ui::ok("Accepted \u{2014} moving on");
            return;
        }

        let feedback = if input.eq_ignore_ascii_case("n") || input.eq_ignore_ascii_case("no") {
            eprint!("  \x1b[1;33mEnter feedback: \x1b[0m");
            let mut fb = String::new();
            if std::io::stdin().read_line(&mut fb).is_err() || fb.trim().is_empty() {
                continue;
            }
            fb.trim().to_string()
        } else {
            input.to_string()
        };

        ui::step("Refining prompt via LLM");
        match refine_prompt_via_llm(&current_text, &feedback, api_key, verbose).await {
            Some(refined) => {
                let preview: String = refined.chars().take(120).collect();
                ui::info(&format!(
                    "Refined prompt: {}{}",
                    preview,
                    if refined.len() > 120 { "..." } else { "" }
                ));

                update_prompt_file(&prompt.meta.path, &current_text, &refined, &feedback);

                prompt.payload.prompt.text = refined.clone();
                current_text = refined;

                ui::step("Regenerating with refined prompt");
                let attachments = load_attachments(prompt).unwrap_or_default();
                let options = GenerationOptions {
                    model: gen_model.to_string(),
                    aspect_ratio: prompt
                        .payload
                        .output
                        .dimensions
                        .as_ref()
                        .and_then(|d| d.aspect_ratio.clone()),
                    negative_prompt: prompt.payload.prompt.negative.clone(),
                    provider_options: prompt.payload.prompt.provider_options.clone(),
                    verbose,
                };

                if let Some(provider) = get_provider(&prompt.meta.service) {
                    for output_path in output_paths {
                        let candidate = genai_candidate_path(output_path);
                        match provider
                            .generate(
                                &current_text,
                                &candidate,
                                api_key,
                                &options,
                                &attachments,
                            )
                            .await
                        {
                            Ok(true) => {
                                if link_active(&candidate, output_path).is_ok() {
                                    ui::ok(&format!("Regenerated: {}", output_path.display()));
                                }
                            }
                            _ => {
                                ui::fail_msg(&format!(
                                    "Regeneration failed: {}",
                                    output_path.display()
                                ));
                            }
                        }
                    }
                }
            }
            None => {
                ui::warn_msg("Refinement failed \u{2014} keeping original prompt");
            }
        }
    }
}

async fn refine_prompt_via_llm(
    original_text: &str,
    feedback: &str,
    api_key: &str,
    verbose: bool,
) -> Option<String> {
    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models/{}:generateContent?key={}",
        REFINE_MODEL, api_key
    );

    let body = json!({
        "contents": [{
            "parts": [{
                "text": format!(
                    "Original prompt:\n{}\n\nUser feedback:\n{}\n\nProduce a refined prompt incorporating the feedback:",
                    original_text, feedback
                )
            }]
        }],
        "systemInstruction": {
            "parts": [{
                "text": "You are a prompt refinement assistant for AI image generation. \
                         Given an original image generation prompt and user feedback about what to change, \
                         produce a refined prompt that incorporates the feedback. \
                         Output ONLY the refined prompt text, nothing else \u{2014} no explanation, no quotes."
            }]
        },
    });

    if verbose {
        ui::verbose(&format!(
            "Refine: POST {}?key=***",
            url.split('?').next().unwrap_or(&url)
        ));
    }

    let client = reqwest::Client::new();
    let resp = client
        .post(&url)
        .header("Content-Type", "application/json")
        .json(&body)
        .timeout(Duration::from_secs(60))
        .send()
        .await
        .ok()?;

    if !resp.status().is_success() {
        ui::fail_msg(&format!("Refinement API returned {}", resp.status()));
        return None;
    }

    let result: serde_json::Value = resp.json().await.ok()?;
    result["candidates"][0]["content"]["parts"][0]["text"]
        .as_str()
        .map(|s| s.trim().to_string())
}

fn update_prompt_file(path: &Path, old_text: &str, new_text: &str, feedback: &str) {
    let Ok(content) = std::fs::read_to_string(path) else {
        return;
    };

    let updated = if content.contains(old_text) {
        content.replacen(old_text, new_text, 1)
    } else {
        // fallback: re-parse and dump
        if let Ok(mut data) = serde_yaml::from_str::<serde_yaml::Value>(&content) {
            if let Some(prompt) = data.get_mut("prompt") {
                if let Some(map) = prompt.as_mapping_mut() {
                    map.insert(
                        serde_yaml::Value::String("text".into()),
                        serde_yaml::Value::String(new_text.into()),
                    );
                }
            }
            serde_yaml::to_string(&data).unwrap_or(content)
        } else {
            content
        }
    };

    let now = chrono_like_now();
    let history = format!(
        "\n# --- Refinement History ---\n\
         # [{}] Feedback: \"{}\"\n\
         # [{}] Refined: \"{}\"\n",
        now,
        &feedback[..feedback.len().min(100)],
        now,
        &new_text[..new_text.len().min(100)]
    );

    let final_content = if updated.contains("# --- Refinement History ---") {
        let trimmed = updated.trim_end_matches('\n');
        format!(
            "{}\n# [{}] Feedback: \"{}\"\n# [{}] Refined: \"{}\"\n",
            trimmed,
            now,
            &feedback[..feedback.len().min(100)],
            now,
            &new_text[..new_text.len().min(100)]
        )
    } else {
        format!("{}{}", updated.trim_end_matches('\n'), history)
    };

    if let Err(e) = std::fs::write(path, final_content) {
        ui::fail_msg(&format!("Failed to update prompt file: {}", e));
    } else {
        ui::ok(&format!("Updated {}", path.display()));
    }
}

fn chrono_like_now() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    // Simple ISO-ish timestamp without pulling in chrono
    let days = secs / 86400;
    let time_of_day = secs % 86400;
    let hours = time_of_day / 3600;
    let minutes = (time_of_day % 3600) / 60;
    let seconds = time_of_day % 60;
    // Approximate date from epoch days (good enough for log entries)
    let (year, month, day) = epoch_days_to_ymd(days);
    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        year, month, day, hours, minutes, seconds
    )
}

fn epoch_days_to_ymd(days: u64) -> (u64, u64, u64) {
    // Civil calendar from epoch days (Rata Die algorithm)
    let z = days + 719468;
    let era = z / 146097;
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = if m <= 2 { y + 1 } else { y };
    (y, m, d)
}
