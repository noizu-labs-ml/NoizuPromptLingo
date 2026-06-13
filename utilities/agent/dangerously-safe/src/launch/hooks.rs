//! Run host-side lifecycle hooks. In-container hooks (on-docker-start) are folded
//! into the container command by [`super`], not run here.

use crate::error::Result;
use anyhow::Context;
use std::path::Path;
use std::process::Command;

/// Run a host hook (relative to the worktree) with the given extra env. The hook
/// runs with its working directory set to the worktree. Missing hooks are a no-op.
pub fn run_host_hook(
    worktree: &Path,
    hook_rel: &str,
    extra_env: &[(String, String)],
    label: &str,
) -> Result<()> {
    let hook = worktree.join(hook_rel);
    if !hook.exists() {
        return Ok(());
    }
    let mut cmd = Command::new(&hook);
    cmd.current_dir(worktree);
    for (k, v) in extra_env {
        cmd.env(k, v);
    }
    let status = cmd
        .status()
        .with_context(|| format!("running {label} hook {hook_rel}"))?;
    if !status.success() {
        anyhow::bail!("{label} hook `{hook_rel}` exited with {status}");
    }
    Ok(())
}
