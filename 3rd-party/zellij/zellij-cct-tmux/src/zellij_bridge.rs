use std::env;
use std::path::PathBuf;
use std::process::{Command, Output};
use std::sync::OnceLock;

use crate::logger;

pub struct BridgeResult {
    pub stdout: String,
    pub stderr: String,
    pub code: i32,
}

/// Invoke `zellij action <args>` as a subprocess targeting the current session.
pub fn action(args: &[&str]) -> BridgeResult {
    let session = discover_session();
    let mut cmd_args = vec!["--session".to_string(), session];
    cmd_args.push("action".into());
    cmd_args.extend(args.iter().map(|s| s.to_string()));
    let refs: Vec<&str> = cmd_args.iter().map(|s| s.as_str()).collect();
    run_zellij(&refs)
}

/// Invoke `zellij <args>` (non-action subcommands like `list-sessions`).
pub fn command(args: &[&str]) -> BridgeResult {
    run_zellij(args)
}

/// Find the real zellij binary, skipping our shim directory.
fn find_zellij() -> &'static str {
    static ZELLIJ_PATH: OnceLock<String> = OnceLock::new();
    ZELLIJ_PATH.get_or_init(|| {
        if let Ok(p) = env::var("ZELLIJ_CCT_REAL_ZELLIJ") {
            return p;
        }

        let our_dir = env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|d| d.to_path_buf()));

        let path_var = env::var("PATH").unwrap_or_default();
        for dir in path_var.split(':') {
            if let Some(ref ours) = our_dir {
                if PathBuf::from(dir) == *ours {
                    continue;
                }
            }
            let candidate = PathBuf::from(dir).join("zellij");
            if candidate.exists() {
                return candidate.to_string_lossy().into_owned();
            }
        }

        // Common install locations as fallback
        for path in &[
            "/opt/homebrew/bin/zellij",
            "/usr/local/bin/zellij",
        ] {
            if PathBuf::from(path).exists() {
                return path.to_string();
            }
        }

        // Last resort: search Homebrew Cellar
        if let Ok(entries) = std::fs::read_dir("/opt/homebrew/Cellar/zellij") {
            let mut versions: Vec<_> = entries.filter_map(|e| e.ok()).collect();
            versions.sort_by(|a, b| b.file_name().cmp(&a.file_name()));
            if let Some(latest) = versions.first() {
                let bin = latest.path().join("bin/zellij");
                if bin.exists() {
                    return bin.to_string_lossy().into_owned();
                }
            }
        }

        if let Ok(home) = env::var("HOME") {
            let cargo = PathBuf::from(&home).join(".cargo/bin/zellij");
            if cargo.exists() {
                return cargo.to_string_lossy().into_owned();
            }
        }

        "zellij".into()
    })
}

/// Return the validated current session name.
pub fn current_session() -> String {
    discover_session()
}

/// Discover the active zellij session name.
/// ZELLIJ_SESSION_NAME can go stale after upgrades, so we verify and fall back
/// to listing sessions if needed.
fn discover_session() -> String {
    static SESSION: OnceLock<String> = OnceLock::new();
    SESSION.get_or_init(|| {
        let env_name = env::var("ZELLIJ_SESSION_NAME").unwrap_or_default();

        // Try the env var first
        if !env_name.is_empty() {
            let check = run_zellij(&["--session", &env_name, "action", "query-tab-names"]);
            if check.code == 0
                && !check.stdout.trim().is_empty()
                && !check.stderr.contains("not found")
            {
                return env_name;
            }
            logger::log_msg(&format!(
                "bridge: ZELLIJ_SESSION_NAME={env_name} is stale, discovering..."
            ));
        }

        // Fall back: use full list-sessions (not --short) so we can skip EXITED sessions
        let list = run_zellij(&["list-sessions"]);
        if list.code == 0 {
            for line in list.stdout.lines() {
                if line.contains("EXITED") {
                    continue;
                }
                let name = strip_ansi(line);
                let name = name.split_whitespace().next().unwrap_or("").trim().to_string();
                if !name.is_empty() {
                    logger::log_msg(&format!("bridge: discovered active session: {name}"));
                    return name;
                }
            }
        }

        logger::log_msg("bridge: no zellij session found, using env var as fallback");
        env_name
    }).clone()
}

fn strip_ansi(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut in_escape = false;
    for ch in s.chars() {
        if in_escape {
            if ch.is_ascii_alphabetic() {
                in_escape = false;
            }
        } else if ch == '\x1b' {
            in_escape = true;
        } else {
            out.push(ch);
        }
    }
    out
}

fn run_zellij(args: &[&str]) -> BridgeResult {
    let zellij = find_zellij();
    logger::log_msg(&format!("bridge: {zellij} {}", args.join(" ")));

    let result = Command::new(zellij).args(args).output();

    match result {
        Ok(output) => {
            let br = to_bridge_result(output);
            if br.code != 0 {
                logger::log_msg(&format!(
                    "bridge: zellij exited {} stderr={}",
                    br.code,
                    br.stderr.trim()
                ));
            }
            br
        }
        Err(e) => {
            logger::log_msg(&format!("bridge: failed to run {zellij}: {e}"));
            BridgeResult {
                stdout: String::new(),
                stderr: format!("failed to run zellij: {e}"),
                code: 127,
            }
        }
    }
}

fn to_bridge_result(output: Output) -> BridgeResult {
    BridgeResult {
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        code: output.status.code().unwrap_or(1),
    }
}

/// Parse a zellij pane ID like "terminal_5" to just the numeric ID.
#[allow(dead_code)]
pub fn parse_zellij_pane_id(s: &str) -> Option<&str> {
    let trimmed = s.trim();
    if trimmed.starts_with("terminal_") {
        Some(trimmed)
    } else if trimmed.chars().all(|c| c.is_ascii_digit()) {
        Some(trimmed)
    } else {
        None
    }
}
