use std::path::Path;
use std::process::Command;
use std::time::Duration;

use serde_json::json;

use crate::prep::PromptPrepper;
use crate::ui;

const MAX_FIX_ATTEMPTS: usize = 2;

pub struct SvgLintError {
    pub message: String,
}

fn run_xmllint(path: &Path) -> Result<(), SvgLintError> {
    match Command::new("xmllint").arg("--noout").arg(path).output() {
        Ok(output) if output.status.success() => Ok(()),
        Ok(output) => {
            let stderr = String::from_utf8_lossy(&output.stderr);
            Err(SvgLintError {
                message: stderr.trim().to_string(),
            })
        }
        Err(_) => Ok(()),
    }
}

pub async fn validate_svg(
    path: &Path,
    verbose: bool,
    prep_llm: Option<&PromptPrepper>,
) -> bool {
    let ext = path.extension().and_then(|e| e.to_str()).unwrap_or("");
    if ext != "svg" {
        return true;
    }

    match run_xmllint(path) {
        Ok(()) => {
            if verbose {
                ui::verbose(&format!("SVG valid: {}", path.display()));
            }
            return true;
        }
        Err(lint_err) => {
            ui::warn_msg(&format!(
                "SVG validation failed for {}: {}",
                path.display(),
                lint_err.message
            ));

            let Some(prepper) = prep_llm else {
                return false;
            };

            for attempt in 0..MAX_FIX_ATTEMPTS {
                ui::step(&format!(
                    "Attempting LLM SVG fix (attempt {}/{})",
                    attempt + 1,
                    MAX_FIX_ATTEMPTS
                ));

                let svg_content = match std::fs::read_to_string(path) {
                    Ok(c) => c,
                    Err(_) => return false,
                };

                let current_err = if attempt == 0 {
                    lint_err.message.clone()
                } else {
                    match run_xmllint(path) {
                        Ok(()) => {
                            if verbose {
                                ui::verbose(&format!(
                                    "SVG fixed after {} attempt(s): {}",
                                    attempt, path.display()
                                ));
                            }
                            return true;
                        }
                        Err(e) => e.message,
                    }
                };

                match request_svg_fix(prepper, &svg_content, &current_err, verbose).await {
                    Some(fixed) => {
                        if let Err(e) = std::fs::write(path, &fixed) {
                            ui::warn_msg(&format!("Failed to write fixed SVG: {}", e));
                            return false;
                        }
                    }
                    None => {
                        ui::warn_msg("LLM SVG fix returned no result");
                        return false;
                    }
                }
            }

            match run_xmllint(path) {
                Ok(()) => {
                    ui::ok(&format!("SVG fixed by LLM: {}", path.display()));
                    true
                }
                Err(e) => {
                    ui::warn_msg(&format!(
                        "SVG still invalid after {} fix attempts: {}",
                        MAX_FIX_ATTEMPTS, e.message
                    ));
                    false
                }
            }
        }
    }
}

async fn request_svg_fix(
    prepper: &PromptPrepper,
    svg_content: &str,
    lint_error: &str,
    verbose: bool,
) -> Option<String> {
    let truncated = if svg_content.len() > 48_000 {
        &svg_content[..48_000]
    } else {
        svg_content
    };

    let instruction = format!(
        r#"You are an SVG repair tool. The following SVG failed XML validation.

XMLLINT ERROR:
{lint_error}

SVG CONTENT:
{truncated}

Fix the SVG so it is well-formed XML. Common issues:
- Unclosed tags
- Unescaped ampersands (& must be &amp;)
- Unescaped < or > inside text/attribute values
- Missing XML namespace on <svg> element
- Mismatched open/close tags
- Invalid attribute quoting

Reply with ONLY the corrected SVG content. No markdown fences, no commentary, no explanation. Start with <?xml or <svg."#
    );

    let url = if prepper.base_url.ends_with("/chat/completions") {
        prepper.base_url.clone()
    } else {
        format!("{}/chat/completions", prepper.base_url)
    };

    let body = json!({
        "model": prepper.model,
        "messages": [{"role": "user", "content": instruction}],
        "temperature": 0.0,
        "max_tokens": 16384,
    });

    let client = reqwest::Client::new();

    if verbose {
        ui::verbose(&format!(
            "SVG fix POST {} ({} chars of SVG)",
            url,
            truncated.len()
        ));
    }

    let resp = match client
        .post(&url)
        .header("Authorization", format!("Bearer {}", prepper.api_key))
        .header("Content-Type", "application/json")
        .json(&body)
        .timeout(Duration::from_secs(120))
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            if verbose {
                ui::verbose(&format!("SVG fix request failed: {}", e));
            }
            return None;
        }
    };

    if !resp.status().is_success() {
        if verbose {
            ui::verbose(&format!("SVG fix HTTP {}", resp.status()));
        }
        return None;
    }

    let val: serde_json::Value = match resp.json().await {
        Ok(v) => v,
        Err(e) => {
            if verbose {
                ui::verbose(&format!("SVG fix response parse error: {}", e));
            }
            return None;
        }
    };

    let raw = val["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .trim()
        .to_string();

    if raw.is_empty() {
        return None;
    }

    // Strip markdown fences if the LLM wrapped the SVG
    let cleaned = strip_svg_fences(&raw);

    if cleaned.contains("<svg") || cleaned.starts_with("<?xml") {
        Some(cleaned)
    } else {
        if verbose {
            ui::verbose("LLM response doesn't look like SVG — discarding");
        }
        None
    }
}

fn strip_svg_fences(s: &str) -> String {
    let s = s.trim();
    if s.starts_with("```") {
        let after_fence = if let Some(nl) = s.find('\n') {
            &s[nl + 1..]
        } else {
            s
        };
        return after_fence.trim_end_matches("```").trim().to_string();
    }
    s.to_string()
}
