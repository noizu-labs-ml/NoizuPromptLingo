use std::collections::HashMap;
use std::fs;
use std::io::{self, Read};

use crate::emoji::emoji_lookup;
use crate::state::state_dir;

/// Find the most recently modified `claude-*.state` file in the state directory.
fn find_latest_claude_state() -> Option<std::path::PathBuf> {
    let dir = state_dir();
    if !dir.is_dir() {
        return None;
    }

    let mut best: Option<(std::path::PathBuf, std::time::SystemTime)> = None;

    if let Ok(entries) = fs::read_dir(&dir) {
        for entry in entries.flatten() {
            let name = entry.file_name();
            let name_str = name.to_string_lossy();
            if name_str.starts_with("claude-") && name_str.ends_with(".state") {
                if let Ok(meta) = entry.metadata() {
                    if meta.is_file() {
                        let mtime = meta.modified().unwrap_or(std::time::UNIX_EPOCH);
                        if best.as_ref().map_or(true, |(_, t)| mtime > *t) {
                            best = Some((entry.path(), mtime));
                        }
                    }
                }
            }
        }
    }

    best.map(|(p, _)| p)
}

/// Parse a key=value state file into a HashMap.
fn parse_state_file(path: &std::path::Path) -> HashMap<String, String> {
    let mut map = HashMap::new();
    if let Ok(content) = fs::read_to_string(path) {
        for line in content.lines() {
            if let Some((key, val)) = line.split_once('=') {
                map.insert(key.to_string(), val.to_string());
            }
        }
    }
    map
}

pub fn run_claude_statusline() {
    // Consume stdin (Claude Code pipes JSON; we don't use it)
    let mut buf = Vec::new();
    let _ = io::stdin().read_to_end(&mut buf);

    // Find the most recent claude-*.state file
    let state_path = match find_latest_claude_state() {
        Some(p) => p,
        None => return, // No state file, exit silently
    };

    let state = parse_state_file(&state_path);

    let title = state.get("title").map(|s| s.as_str()).unwrap_or("");
    let status = state.get("status").map(|s| s.as_str()).unwrap_or("");
    let emoji_name = state.get("emoji").map(|s| s.as_str()).unwrap_or("");

    // Nothing to show
    if title.is_empty() && status.is_empty() {
        return;
    }

    let mut out = String::new();

    // Resolve emoji name to unicode char
    if !emoji_name.is_empty() {
        if let Some(ch) = emoji_lookup(emoji_name) {
            out.push_str(ch);
        } else {
            // Use the raw name as-is if not found (might already be a unicode char)
            out.push_str(emoji_name);
        }
        out.push(' ');
    }

    // Add title
    out.push_str(title);

    // Add status
    if !status.is_empty() {
        out.push_str(": ");
        out.push_str(status);
    }

    println!("{}", out);
}
