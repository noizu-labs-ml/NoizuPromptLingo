#![allow(dead_code)]
// toggl.rs — Toggl Track API integration for tabbing-on
//
// Mirrors the shell-impl/lib/toggl.sh behavior: creates/stops/updates
// time entries in Toggl Track that track tabbing-on task lifecycle.
//
// All operations are optional — if TAB_TOGGL_TOKEN is unset, every
// public function is a silent no-op.

use std::env;
use std::time::Duration;

use serde::{Deserialize, Serialize};

use crate::state::TabState;

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------

#[derive(Debug, Deserialize)]
pub struct Workspace {
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct Project {
    pub id: u64,
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct TimeEntry {
    pub id: u64,
    pub description: Option<String>,
    pub workspace_id: u64,
    pub project_id: Option<u64>,
    pub start: Option<String>,
    pub duration: i64,
}

#[derive(Debug, Serialize)]
struct CreateEntryPayload {
    description: String,
    workspace_id: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    project_id: Option<u64>,
    tags: Vec<String>,
    start: String,
    duration: i64,
    created_with: String,
    billable: bool,
}

#[derive(Debug, Serialize)]
struct UpdateEntryPayload {
    description: String,
}

// ---------------------------------------------------------------------------
// Client
// ---------------------------------------------------------------------------

const API_BASE: &str = "https://api.track.toggl.com/api/v9";
const TIMEOUT_SECS: u64 = 5;

pub struct TogglClient {
    token: String,
    client: reqwest::blocking::Client,
    workspace_id: Option<u64>,
    project_id: Option<u64>,
}

impl TogglClient {
    pub fn new(token: &str) -> Self {
        let client = reqwest::blocking::Client::builder()
            .timeout(Duration::from_secs(TIMEOUT_SECS))
            .build()
            .unwrap_or_else(|_| reqwest::blocking::Client::new());

        Self {
            token: token.to_string(),
            client,
            workspace_id: None,
            project_id: None,
        }
    }

    /// Create a client from environment variables.
    /// Returns None if TAB_TOGGL_TOKEN is not set.
    pub fn from_env() -> Option<Self> {
        let token = env::var("TAB_TOGGL_TOKEN").ok()?;
        if token.is_empty() {
            return None;
        }
        let mut c = Self::new(&token);
        c.workspace_id = env::var("TAB_TOGGL_WORKSPACE")
            .ok()
            .and_then(|v| v.parse().ok());
        c.project_id = env::var("TAB_TOGGL_PROJECT")
            .ok()
            .and_then(|v| v.parse().ok());
        Some(c)
    }

    // -- Workspace resolution -------------------------------------------------

    /// Resolve workspace ID: from config, or auto-detect first workspace.
    fn resolve_workspace_id(&mut self) -> Option<u64> {
        if let Some(id) = self.workspace_id {
            return Some(id);
        }
        let workspaces = self.get_workspaces();
        if let Some(first) = workspaces.first() {
            self.workspace_id = Some(first.id);
            return Some(first.id);
        }
        None
    }

    // -- API methods ----------------------------------------------------------

    pub fn get_workspaces(&self) -> Vec<Workspace> {
        let url = format!("{}/me/workspaces", API_BASE);
        match self
            .client
            .get(&url)
            .basic_auth(&self.token, Some("api_token"))
            .header("Content-Type", "application/json")
            .send()
        {
            Ok(resp) if resp.status().is_success() => {
                resp.json::<Vec<Workspace>>().unwrap_or_default()
            }
            Ok(resp) => {
                eprintln!(
                    "tabbing-toggl: GET /me/workspaces returned {}",
                    resp.status()
                );
                Vec::new()
            }
            Err(e) => {
                eprintln!("tabbing-toggl: workspaces request failed: {}", e);
                Vec::new()
            }
        }
    }

    pub fn get_projects(&self, workspace_id: u64) -> Vec<Project> {
        let url = format!("{}/workspaces/{}/projects", API_BASE, workspace_id);
        match self
            .client
            .get(&url)
            .basic_auth(&self.token, Some("api_token"))
            .header("Content-Type", "application/json")
            .send()
        {
            Ok(resp) if resp.status().is_success() => {
                resp.json::<Vec<Project>>().unwrap_or_default()
            }
            _ => Vec::new(),
        }
    }

    pub fn create_time_entry(
        &self,
        workspace_id: u64,
        description: &str,
        project_id: Option<u64>,
        tags: &[String],
        billable: bool,
    ) -> Option<u64> {
        let url = format!("{}/workspaces/{}/time_entries", API_BASE, workspace_id);
        let now = chrono::Utc::now().format("%Y-%m-%dT%H:%M:%S.000Z").to_string();

        let payload = CreateEntryPayload {
            description: description.to_string(),
            workspace_id,
            project_id,
            tags: tags.to_vec(),
            start: now,
            duration: -1, // running
            created_with: "tabbing-on".to_string(),
            billable,
        };

        match self
            .client
            .post(&url)
            .basic_auth(&self.token, Some("api_token"))
            .json(&payload)
            .send()
        {
            Ok(resp) if resp.status().is_success() => {
                let body: serde_json::Value = resp.json().ok()?;
                body.get("id").and_then(|v| v.as_u64())
            }
            Ok(resp) => {
                eprintln!(
                    "tabbing-toggl: create entry failed (HTTP {})",
                    resp.status()
                );
                None
            }
            Err(e) => {
                eprintln!("tabbing-toggl: create entry request failed: {}", e);
                None
            }
        }
    }

    pub fn stop_time_entry(&self, workspace_id: u64, entry_id: u64) {
        let url = format!(
            "{}/workspaces/{}/time_entries/{}/stop",
            API_BASE, workspace_id, entry_id
        );
        match self
            .client
            .patch(&url)
            .basic_auth(&self.token, Some("api_token"))
            .header("Content-Type", "application/json")
            .send()
        {
            Ok(resp) if resp.status().is_success() || resp.status().as_u16() == 409 => {
                // 409 = already stopped, that's fine
            }
            Ok(resp) => {
                eprintln!(
                    "tabbing-toggl: stop entry {} failed (HTTP {})",
                    entry_id,
                    resp.status()
                );
            }
            Err(e) => {
                eprintln!("tabbing-toggl: stop entry request failed: {}", e);
            }
        }
    }

    pub fn get_current_entry(&self) -> Option<TimeEntry> {
        let url = format!("{}/me/time_entries/current", API_BASE);
        match self
            .client
            .get(&url)
            .basic_auth(&self.token, Some("api_token"))
            .header("Content-Type", "application/json")
            .send()
        {
            Ok(resp) if resp.status().is_success() => {
                // Toggl returns `null` (not an object) when no entry is running.
                let text = resp.text().ok()?;
                if text.trim() == "null" {
                    return None;
                }
                serde_json::from_str::<TimeEntry>(&text).ok()
            }
            _ => None,
        }
    }

    pub fn update_time_entry(
        &self,
        workspace_id: u64,
        entry_id: u64,
        description: &str,
    ) {
        let url = format!(
            "{}/workspaces/{}/time_entries/{}",
            API_BASE, workspace_id, entry_id
        );
        let payload = UpdateEntryPayload {
            description: description.to_string(),
        };
        let _ = self
            .client
            .put(&url)
            .basic_auth(&self.token, Some("api_token"))
            .json(&payload)
            .send();
    }
}

// ---------------------------------------------------------------------------
// Description formatting
// ---------------------------------------------------------------------------

/// Build a Toggl description from title and status.
/// Format: "title -- status" when status is non-empty, otherwise just "title".
pub fn format_description(title: &str, status: &str) -> String {
    if status.is_empty() {
        title.to_string()
    } else {
        format!("{} \u{2014} {}", title, status) // em-dash
    }
}

// ---------------------------------------------------------------------------
// Config helpers
// ---------------------------------------------------------------------------

fn parse_tags() -> Vec<String> {
    env::var("TAB_TOGGL_TAGS")
        .unwrap_or_default()
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect()
}

fn parse_billable() -> bool {
    env::var("TAB_TOGGL_BILLABLE")
        .map(|v| v == "true")
        .unwrap_or(false)
}

fn get_entry_id() -> Option<u64> {
    env::var("TAB_TOGGL_ENTRY_ID")
        .ok()
        .and_then(|v| v.parse().ok())
}

// ---------------------------------------------------------------------------
// Integration points — called from main.rs
// ---------------------------------------------------------------------------

/// Called after title changes in cmd_tabbing_on().
///
/// - No running entry: create one
/// - Running entry with same title prefix: update description
/// - Running entry with different title: stop old, create new
pub fn toggl_on_title_change(state: &TabState) {
    let mut client = match TogglClient::from_env() {
        Some(c) => c,
        None => return,
    };

    let ws_id = match client.resolve_workspace_id() {
        Some(id) => id,
        None => {
            eprintln!("tabbing-toggl: could not resolve workspace");
            return;
        }
    };

    let new_desc = format_description(&state.title, &state.status);
    let tags = parse_tags();
    let billable = parse_billable();

    match get_entry_id() {
        Some(entry_id) => {
            // We have a tracked entry — check if title prefix changed
            if let Some(current) = client.get_current_entry() {
                let current_desc = current.description.unwrap_or_default();
                let current_prefix = current_desc.split(" \u{2014} ").next().unwrap_or("");
                if current_prefix == state.title {
                    // Same title, just update the description (status may have changed)
                    client.update_time_entry(ws_id, entry_id, &new_desc);
                } else {
                    // Different title — stop old, start new
                    client.stop_time_entry(ws_id, entry_id);
                    if let Some(new_id) =
                        client.create_time_entry(ws_id, &new_desc, client.project_id, &tags, billable)
                    {
                        println!("export TAB_TOGGL_ENTRY_ID='{}'", new_id);
                    }
                }
            } else {
                // No running entry in Toggl (stopped externally?) — start fresh
                if let Some(new_id) =
                    client.create_time_entry(ws_id, &new_desc, client.project_id, &tags, billable)
                {
                    println!("export TAB_TOGGL_ENTRY_ID='{}'", new_id);
                }
            }
        }
        None => {
            // No entry tracked — create a new one
            if let Some(new_id) =
                client.create_time_entry(ws_id, &new_desc, client.project_id, &tags, billable)
            {
                println!("export TAB_TOGGL_ENTRY_ID='{}'", new_id);
            }
        }
    }
}

/// Called after status changes in cmd_tabbing_status().
/// Updates the running entry description if one exists.
pub fn toggl_on_status_change(state: &TabState) {
    let mut client = match TogglClient::from_env() {
        Some(c) => c,
        None => return,
    };

    let entry_id = match get_entry_id() {
        Some(id) => id,
        None => return,
    };

    let ws_id = match client.resolve_workspace_id() {
        Some(id) => id,
        None => return,
    };

    let new_desc = format_description(&state.title, &state.status);
    client.update_time_entry(ws_id, entry_id, &new_desc);
}

/// Called from cmd_tabbing_off(). Stops the current running entry.
pub fn toggl_on_off() {
    let mut client = match TogglClient::from_env() {
        Some(c) => c,
        None => return,
    };

    let entry_id = match get_entry_id() {
        Some(id) => id,
        None => return,
    };

    let ws_id = match client.resolve_workspace_id() {
        Some(id) => id,
        None => return,
    };

    client.stop_time_entry(ws_id, entry_id);
    eprintln!("tabbing-toggl: timer stopped (entry {})", entry_id);
}

/// Print current Toggl tracking state to stderr.
pub fn toggl_status() {
    let mut client = match TogglClient::from_env() {
        Some(c) => c,
        None => {
            eprintln!("tabbing-toggl: TAB_TOGGL_TOKEN not set");
            return;
        }
    };

    let entry_id = match get_entry_id() {
        Some(id) => id,
        None => {
            eprintln!("tabbing-toggl: no active entry");
            return;
        }
    };

    let ws_id = match client.resolve_workspace_id() {
        Some(id) => id,
        None => {
            eprintln!("tabbing-toggl: could not resolve workspace");
            return;
        }
    };

    match client.get_current_entry() {
        Some(entry) if entry.id == entry_id => {
            let desc = entry.description.unwrap_or_else(|| "(no description)".to_string());
            let duration_display = if entry.duration < 0 {
                // Running — compute elapsed from start
                let elapsed = entry
                    .start
                    .as_ref()
                    .and_then(|s| chrono::DateTime::parse_from_rfc3339(s).ok())
                    .map(|start| {
                        let now = chrono::Utc::now();
                        (now - start.with_timezone(&chrono::Utc))
                            .num_seconds()
                            .max(0)
                    })
                    .unwrap_or(0);
                format_duration(elapsed)
            } else {
                format_duration(entry.duration)
            };

            eprintln!("  Entry:       {} (running)", entry_id);
            eprintln!("  Description: {}", desc);
            eprintln!("  Duration:    {}", duration_display);
            eprintln!("  Workspace:   {}", ws_id);
            if let Some(pid) = entry.project_id {
                eprintln!("  Project:     {}", pid);
            }
        }
        _ => {
            eprintln!("tabbing-toggl: entry {} not currently running", entry_id);
        }
    }
}

fn format_duration(seconds: i64) -> String {
    let h = seconds / 3600;
    let m = (seconds % 3600) / 60;
    let s = seconds % 60;
    if h > 0 {
        format!("{}h {:02}m {:02}s", h, m, s)
    } else {
        format!("{}m {:02}s", m, s)
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_description_with_status() {
        assert_eq!(
            format_description("MyApp", "deploying"),
            "MyApp \u{2014} deploying"
        );
    }

    #[test]
    fn test_format_description_without_status() {
        assert_eq!(format_description("MyApp", ""), "MyApp");
    }

    #[test]
    fn test_format_description_preserves_unicode() {
        assert_eq!(
            format_description("TabApp", "\u{1f680} launching"),
            "TabApp \u{2014} \u{1f680} launching"
        );
    }

    #[test]
    fn test_format_duration_seconds() {
        assert_eq!(format_duration(45), "0m 45s");
    }

    #[test]
    fn test_format_duration_minutes() {
        assert_eq!(format_duration(125), "2m 05s");
    }

    #[test]
    fn test_format_duration_hours() {
        assert_eq!(format_duration(3661), "1h 01m 01s");
    }

    #[test]
    fn test_parse_tags_empty_and_csv() {
        env::remove_var("TAB_TOGGL_TAGS");
        assert!(parse_tags().is_empty());

        env::set_var("TAB_TOGGL_TAGS", "work, billing, project-x");
        assert_eq!(parse_tags(), vec!["work", "billing", "project-x"]);
        env::remove_var("TAB_TOGGL_TAGS");
    }

    #[test]
    fn test_parse_billable_variants() {
        env::remove_var("TAB_TOGGL_BILLABLE");
        assert!(!parse_billable());

        env::set_var("TAB_TOGGL_BILLABLE", "true");
        assert!(parse_billable());

        env::set_var("TAB_TOGGL_BILLABLE", "false");
        assert!(!parse_billable());

        env::remove_var("TAB_TOGGL_BILLABLE");
    }

    // NOTE: env var tests that set/remove the same key must run in a single
    // test to avoid races — Rust tests run in parallel within one process.

    #[test]
    fn test_entry_id_env_roundtrip_and_missing_and_invalid() {
        // roundtrip
        env::set_var("TAB_TOGGL_ENTRY_ID", "123456789");
        assert_eq!(get_entry_id(), Some(123456789));

        // missing
        env::remove_var("TAB_TOGGL_ENTRY_ID");
        assert_eq!(get_entry_id(), None);

        // invalid
        env::set_var("TAB_TOGGL_ENTRY_ID", "not-a-number");
        assert_eq!(get_entry_id(), None);
        env::remove_var("TAB_TOGGL_ENTRY_ID");
    }

    #[test]
    fn test_client_from_env_missing_and_empty_token() {
        env::remove_var("TAB_TOGGL_TOKEN");
        assert!(TogglClient::from_env().is_none());

        env::set_var("TAB_TOGGL_TOKEN", "");
        assert!(TogglClient::from_env().is_none());
        env::remove_var("TAB_TOGGL_TOKEN");
    }
}
