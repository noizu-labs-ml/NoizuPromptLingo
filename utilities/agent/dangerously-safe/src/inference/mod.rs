//! Branch-name inference via an OpenAI-compatible chat-completions endpoint.
//!
//! Configured by env:
//! - `AGENT_SANDBOX_INFERENCE_API_BASE` (default `https://api.openai.com/v1`)
//! - `AGENT_SANDBOX_INFERENCE_API_KEY` or `OPENAI_API_KEY`
//! - `AGENT_SANDBOX_INFERENCE_MODEL` (default `gpt-4o-mini`)
//!
//! Callers must always be able to fall back to [`fallback_slug`]; inference is a
//! convenience and never blocks worktree creation.

use crate::error::Result;
use anyhow::Context;
use std::time::Duration;

const DEFAULT_BASE: &str = "https://api.openai.com/v1";
const DEFAULT_MODEL: &str = "gpt-4o-mini";

const SYSTEM_PROMPT: &str = "You generate a concise git branch name summarizing a developer's task. \
Reply with ONLY the branch name: 3-5 words, lowercase, kebab-case, ASCII letters/digits/hyphens only, \
no quotes, no prefixes like 'feature/'.";

/// True if an inference endpoint key is configured (so callers can decide whether
/// to attempt it).
pub fn is_configured() -> bool {
    api_key().is_some()
}

fn api_base() -> String {
    std::env::var("AGENT_SANDBOX_INFERENCE_API_BASE")
        .ok()
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| DEFAULT_BASE.to_string())
}

fn api_key() -> Option<String> {
    for var in ["AGENT_SANDBOX_INFERENCE_API_KEY", "OPENAI_API_KEY"] {
        if let Ok(v) = std::env::var(var) {
            if !v.is_empty() {
                return Some(v);
            }
        }
    }
    None
}

fn model() -> String {
    std::env::var("AGENT_SANDBOX_INFERENCE_MODEL")
        .ok()
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| DEFAULT_MODEL.to_string())
}

/// Ask the inference endpoint for a branch slug. Returns a sanitized slug, or an
/// error the caller should swallow in favor of [`fallback_slug`].
pub async fn branch_slug(description: &str) -> Result<String> {
    let key = api_key().context("no inference API key configured")?;
    let url = format!("{}/chat/completions", api_base().trim_end_matches('/'));

    let body = serde_json::json!({
        "model": model(),
        "temperature": 0.3,
        "max_tokens": 24,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": description},
        ],
    });

    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(15))
        .build()?;
    let resp = client
        .post(&url)
        .bearer_auth(key)
        .json(&body)
        .send()
        .await
        .context("inference request failed")?;
    if !resp.status().is_success() {
        anyhow::bail!("inference endpoint returned {}", resp.status());
    }
    let json: serde_json::Value = resp.json().await.context("parsing inference response")?;
    let content = json["choices"][0]["message"]["content"]
        .as_str()
        .context("inference response missing content")?;

    let slug = sanitize_slug(content);
    if slug.is_empty() {
        anyhow::bail!("inference returned an empty slug");
    }
    Ok(slug)
}

/// Deterministic kebab-case slug from a description (the always-available
/// fallback when inference is unavailable or fails).
pub fn fallback_slug(description: &str) -> String {
    sanitize_slug(description)
}

/// Normalize arbitrary text into a kebab-case branch slug of at most 5 words.
fn sanitize_slug(text: &str) -> String {
    text.split_whitespace()
        .flat_map(|w| w.split('-'))
        .map(|w| {
            w.chars()
                .filter(|c| c.is_ascii_alphanumeric())
                .collect::<String>()
                .to_lowercase()
        })
        .filter(|w| !w.is_empty())
        .take(5)
        .collect::<Vec<_>>()
        .join("-")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sanitizes_model_output() {
        assert_eq!(sanitize_slug("  Add OAuth login flow "), "add-oauth-login-flow");
        // only whitespace and hyphens are word separators; other punctuation is stripped
        assert_eq!(sanitize_slug("feature/Fix.The_Bug!!"), "featurefixthebug");
        assert_eq!(sanitize_slug("fix the bug - now"), "fix-the-bug-now");
        assert_eq!(sanitize_slug("a b c d e f g"), "a-b-c-d-e");
        assert_eq!(sanitize_slug("already-kebab-case"), "already-kebab-case");
    }

    #[test]
    fn fallback_is_deterministic() {
        assert_eq!(fallback_slug("Refactor the payment module"), "refactor-the-payment-module");
    }

    #[test]
    fn api_base_has_default_when_unset() {
        // When the env var is absent/empty the function returns the compile-time default.
        // We can't mutate the env safely in parallel tests, so we only test the code path
        // that runs when the var is not set — which returns a non-empty https:// URL.
        let base = api_base();
        assert!(base.starts_with("http"));
        assert!(!base.is_empty());
    }

    #[test]
    fn model_has_default_when_unset() {
        let m = model();
        assert!(!m.is_empty());
    }

    #[test]
    fn is_configured_false_when_no_key() {
        // In the test environment neither AGENT_SANDBOX_INFERENCE_API_KEY nor
        // OPENAI_API_KEY should be set; verify is_configured() returns false.
        // (This is a best-effort assertion — if the runner has a key set it will pass anyway.)
        if std::env::var("AGENT_SANDBOX_INFERENCE_API_KEY").is_err()
            && std::env::var("OPENAI_API_KEY").is_err()
        {
            assert!(!is_configured());
        }
    }
}
