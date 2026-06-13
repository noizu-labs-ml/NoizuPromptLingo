//! Stage host CLI tools into the worktree so they're available (and on PATH)
//! inside the container.

use crate::config::ToolsConfig;
use crate::paths;
use std::path::Path;

/// In-container PATH entry for staged binaries.
pub const CONTAINER_TOOL_BIN: &str = "/work/.agent-sandbox/local/bin";

/// Copy configured tools from `~/.local/{bin,share}` into the worktree's
/// `.agent-sandbox/local/{bin,share}`. Returns non-fatal warnings.
pub fn stage_tools(cfg: &ToolsConfig, worktree: &Path) -> Vec<String> {
    let mut warnings = Vec::new();

    let dest_bin = worktree.join(".agent-sandbox/local/bin");
    let dest_share = worktree.join(".agent-sandbox/local/share");
    for d in [&dest_bin, &dest_share] {
        if let Err(e) = std::fs::create_dir_all(d) {
            warnings.push(format!("could not create {}: {e}", d.display()));
        }
    }

    for name in &cfg.copy_bins {
        let src = paths::local_bin().join(name);
        if !src.exists() {
            warnings.push(format!("tool `{name}` not found in ~/.local/bin; skipped"));
            continue;
        }
        let dst = dest_bin.join(name);
        if let Err(e) = copy_file_preserve_mode(&src, &dst) {
            warnings.push(format!("copy {name}: {e}"));
        }
    }

    for name in &cfg.copy_shares {
        let src = paths::local_share().join(name);
        if !src.exists() {
            warnings.push(format!(
                "shared tool `{name}` not found in ~/.local/share; skipped"
            ));
            continue;
        }
        let dst = dest_share.join(name);
        if let Err(e) = copy_recursive(&src, &dst) {
            warnings.push(format!("copy {name}: {e}"));
        }
    }

    warnings
}

fn copy_file_preserve_mode(src: &Path, dst: &Path) -> std::io::Result<()> {
    std::fs::copy(src, dst)?;
    Ok(())
}

fn copy_recursive(src: &Path, dst: &Path) -> std::io::Result<()> {
    if src.is_dir() {
        std::fs::create_dir_all(dst)?;
        for entry in std::fs::read_dir(src)? {
            let entry = entry?;
            copy_recursive(&entry.path(), &dst.join(entry.file_name()))?;
        }
    } else {
        if let Some(parent) = dst.parent() {
            std::fs::create_dir_all(parent)?;
        }
        std::fs::copy(src, dst)?;
    }
    Ok(())
}
