//! XDG path resolution for agent-sandbox.
//!
//! Layout:
//! - config/templates: `~/.config/agent-sandbox/{templates,snippets,infra}`
//! - shared data:      `~/.local/share/agent-sandbox/snippets`
//! - host tool source: `~/.local/{bin,share}`
//!
//! Snippet lookups prefer the user config dir over the shared-data dir so users
//! can override shipped snippets (same override pattern as the direnv stdlib).

use std::path::PathBuf;

pub const TOOL_NAME: &str = "agent-sandbox";

/// The per-project config directory name placed at a repo root.
pub const PROJECT_DIR: &str = ".agent-sandbox";

/// File name of the per-project config inside [`PROJECT_DIR`].
pub const CONFIG_FILE: &str = "config";

/// `$XDG_CONFIG_HOME/agent-sandbox` or `~/.config/agent-sandbox`.
///
/// We follow XDG explicitly (not `dirs::config_dir`, which maps to
/// `~/Library/Application Support` on macOS) to match the repo's install
/// convention and the Makefile's install paths across platforms.
pub fn config_dir() -> PathBuf {
    xdg_base("XDG_CONFIG_HOME", ".config").join(TOOL_NAME)
}

/// `$XDG_DATA_HOME/agent-sandbox` or `~/.local/share/agent-sandbox`.
pub fn data_dir() -> PathBuf {
    xdg_base("XDG_DATA_HOME", ".local/share").join(TOOL_NAME)
}

/// `~/.config/agent-sandbox/templates`
pub fn templates_dir() -> PathBuf {
    config_dir().join("templates")
}

/// Snippet search path, highest priority first.
pub fn snippet_dirs() -> Vec<PathBuf> {
    vec![config_dir().join("snippets"), data_dir().join("snippets")]
}

/// `~/.local/bin` — where host CLI tools (docker-build, docker-rebuild) live.
pub fn local_bin() -> PathBuf {
    home().join(".local/bin")
}

/// `~/.local/share` — where host shared libs (k8-lib) live.
pub fn local_share() -> PathBuf {
    home().join(".local/share")
}

pub fn home() -> PathBuf {
    dirs::home_dir().unwrap_or_else(|| PathBuf::from("/"))
}

fn xdg_base(var: &str, fallback_rel: &str) -> PathBuf {
    xdg_base_value(std::env::var_os(var), fallback_rel)
}

fn xdg_base_value(val: Option<std::ffi::OsString>, fallback_rel: &str) -> PathBuf {
    match val {
        Some(v) if !v.is_empty() => PathBuf::from(v),
        _ => home().join(fallback_rel),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::OsString;

    #[test]
    fn xdg_base_value_uses_override() {
        let r = xdg_base_value(Some(OsString::from("/custom/xdg")), ".config");
        assert_eq!(r, PathBuf::from("/custom/xdg"));
    }

    #[test]
    fn xdg_base_value_ignores_empty_override() {
        let r = xdg_base_value(Some(OsString::from("")), ".config");
        assert!(r.ends_with(".config"));
    }

    #[test]
    fn xdg_base_value_uses_fallback_when_none() {
        let r = xdg_base_value(None, ".local/share");
        assert!(r.ends_with(".local/share"));
    }

    #[test]
    fn config_dir_ends_with_tool_name() {
        assert!(config_dir().ends_with(TOOL_NAME));
    }

    #[test]
    fn data_dir_ends_with_tool_name() {
        assert!(data_dir().ends_with(TOOL_NAME));
    }

    #[test]
    fn snippet_dirs_length() {
        assert_eq!(snippet_dirs().len(), 2);
    }
}
