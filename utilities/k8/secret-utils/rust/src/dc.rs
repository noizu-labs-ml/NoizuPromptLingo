use anyhow::{Context, Result};
use regex::Regex;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use crate::error::InfisicalError;

// ── dc CLI wrapper ────────────────────────────────────────────────────────────

/// Run `dc get <scope> <item_path>` and return the value string
pub fn dc_get(scope: &str, item_path: &str) -> Result<String> {
    let output = std::process::Command::new("dc")
        .args(["get", scope, item_path])
        .output()
        .context("run dc get — is 'dc' on PATH?")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(InfisicalError::DcCli(format!(
            "dc get {scope} {item_path}: {stderr}"
        ))
        .into());
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

/// Run `dc set <scope> <item_path> <value>`
pub fn dc_set(scope: &str, item_path: &str, value: &str) -> Result<()> {
    let status = std::process::Command::new("dc")
        .args(["set", scope, item_path, value])
        .status()
        .context("run dc set")?;

    if !status.success() {
        return Err(InfisicalError::DcCli(format!(
            "dc set {scope} {item_path}: exited {status}"
        ))
        .into());
    }
    Ok(())
}

/// Try `dc get`, return None on failure (for optional lookups)
pub fn dc_get_optional(scope: &str, item_path: &str) -> Option<String> {
    dc_get(scope, item_path).ok().filter(|s| !s.is_empty())
}

// ── .envrc.dc parser ──────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct DcDirective {
    pub line_number: usize,
    pub scope: String,
    pub item_path: String,
    pub raw_line: String,
}

static DC_REGEX: OnceLock<Regex> = OnceLock::new();

fn dc_regex() -> &'static Regex {
    DC_REGEX.get_or_init(|| {
        Regex::new(r"dc\s+get\s+(\S+)\s+(\S+)").unwrap()
    })
}

/// Parse all `dc get SCOPE ITEM.PATH` directives from a .envrc.dc file
pub fn parse_envrc_dc(path: &Path) -> Result<Vec<DcDirective>> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("read {:?}", path))?;

    let re = dc_regex();
    let mut results = Vec::new();

    for (idx, line) in content.lines().enumerate() {
        if let Some(caps) = re.captures(line) {
            results.push(DcDirective {
                line_number: idx + 1,
                scope: caps[1].to_owned(),
                item_path: caps[2].to_owned(),
                raw_line: line.to_owned(),
            });
        }
    }

    Ok(results)
}

/// Find a specific directive by scope + item_path
pub fn find_dc_directive(
    path: &Path,
    scope: &str,
    item_path: &str,
) -> Result<Option<DcDirective>> {
    let directives = parse_envrc_dc(path)?;
    Ok(directives
        .into_iter()
        .find(|d| d.scope == scope && d.item_path == item_path))
}

/// Replace the content of a specific line in a file (1-indexed)
#[allow(dead_code)]
pub fn edit_line(path: &Path, line_number: usize, new_content: &str, backup: bool) -> Result<()> {
    let content = std::fs::read_to_string(path)?;
    let mut lines: Vec<&str> = content.lines().collect();

    if line_number == 0 || line_number > lines.len() {
        anyhow::bail!("line {} out of range (file has {} lines)", line_number, lines.len());
    }

    if backup {
        let bak = format!("{}.bak", path.display());
        std::fs::copy(path, &bak)?;
    }

    lines[line_number - 1] = new_content;
    std::fs::write(path, lines.join("\n") + "\n")?;
    Ok(())
}

// ── .envrc.dc discovery ───────────────────────────────────────────────────────

/// Walk up from cwd to find .envrc.dc
pub fn find_envrc_dc() -> Result<PathBuf> {
    let mut dir = std::env::current_dir()?;
    loop {
        let candidate = dir.join(".envrc.dc");
        if candidate.exists() {
            return Ok(candidate);
        }
        if !dir.pop() {
            break;
        }
    }
    Err(InfisicalError::EnvrcNotFound.into())
}
