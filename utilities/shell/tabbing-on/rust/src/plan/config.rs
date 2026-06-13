use std::env;
use std::path::Component;

use super::types::{AppConfig, TicketType};

/// Walk up from cwd looking for a "projects" parent segment.
/// If found, the next segment is the project name.
fn infer_project() -> Option<String> {
    let cwd = env::current_dir().ok()?;
    let parts: Vec<&str> = cwd
        .components()
        .filter_map(|c| match c {
            Component::Normal(s) => s.to_str(),
            _ => None,
        })
        .collect();

    for i in 1..parts.len() {
        if parts[i - 1] == "projects" {
            return Some(parts[i].to_string());
        }
    }

    None
}

fn env_non_empty(key: &str) -> Option<String> {
    env::var(key).ok().filter(|v| !v.is_empty())
}

/// Resolve the application config from CLI flags, env vars, and defaults.
///
/// Precedence (highest wins): flag -> env var -> built-in default
pub fn resolve_config(
    project: Option<String>,
    ticket_type: Option<String>,
    api_url: Option<String>,
    api_key: Option<String>,
    model: Option<String>,
    whisper_model: Option<String>,
    output_dir: Option<String>,
    no_tabbing: bool,
) -> AppConfig {
    let api_url = api_url
        .or_else(|| env_non_empty("LITELLM_API_URL"))
        .unwrap_or_else(|| "http://inference.noizu.com/v1".to_string());

    let api_key = api_key
        .or_else(|| env_non_empty("LITELLM_API_KEY"))
        .unwrap_or_default();

    let model = model
        .or_else(|| env_non_empty("M2T_MODEL"))
        .unwrap_or_else(|| "gpt-4".to_string());

    let whisper_model = whisper_model
        .or_else(|| env_non_empty("M2T_WHISPER_MODEL"))
        .unwrap_or_else(|| "whisper-1".to_string());

    let ticket_type = ticket_type.and_then(|t| match t.as_str() {
        "user-story" => Some(TicketType::UserStory),
        "bug" => Some(TicketType::Bug),
        "task" => Some(TicketType::Task),
        _ => None,
    });

    let project = project.or_else(infer_project);

    AppConfig {
        project,
        ticket_type,
        api_url,
        api_key,
        model,
        whisper_model,
        output_dir,
        no_tabbing,
    }
}
