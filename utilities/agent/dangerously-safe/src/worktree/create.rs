//! Create a new managed worktree. Ports the logic from the legacy
//! `bin/dangerously-safe` bash script: worktree add, rsync untracked files,
//! restrict-access hook, ownership change.

use crate::config::{Project, WorktreeConfig};
use crate::error::Result;
use anyhow::Context;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Result of creating a worktree, including non-fatal warnings to surface.
#[derive(Debug, Clone)]
pub struct CreateOutcome {
    pub path: PathBuf,
    pub branch: String,
    pub warnings: Vec<String>,
}

/// Create a worktree for `desired_slug` branched from `origin`. If the branch
/// already exists, a numeric suffix is appended. Returns the final path/branch.
pub fn create_worktree(
    project: &Project,
    cfg: &WorktreeConfig,
    desired_slug: &str,
    origin: &str,
) -> Result<CreateOutcome> {
    let root = project.root.join(&cfg.root);
    std::fs::create_dir_all(&root)
        .with_context(|| format!("creating worktrees root {}", root.display()))?;

    let branch = unique_branch(project, desired_slug)?;
    let path = root.join(&branch);

    // git worktree add <path> -b <branch> <origin>
    let status = Command::new("git")
        .arg("-C")
        .arg(&project.root)
        .args(["worktree", "add"])
        .arg(&path)
        .arg("-b")
        .arg(&branch)
        .arg(origin)
        .status()
        .context("git worktree add")?;
    if !status.success() {
        anyhow::bail!("git worktree add failed for {}", path.display());
    }

    let mut warnings = Vec::new();

    if cfg.rsync_untracked {
        if let Err(e) = rsync_untracked(project, &cfg.root, &path) {
            warnings.push(format!("rsync of untracked files failed: {e}"));
        }
    }

    if let Some(hook) = &cfg.restrict_access_hook {
        run_restrict_hook(&path, hook, &mut warnings);
    }

    if let (Some(user), Some(group)) = (&cfg.owner_user, &cfg.owner_group) {
        chown_best_effort(&path, user, group, &mut warnings);
    }

    Ok(CreateOutcome {
        path,
        branch,
        warnings,
    })
}

/// Pick a branch name that doesn't already exist, appending `-2`, `-3`, ...
fn unique_branch(project: &Project, desired: &str) -> Result<String> {
    let base = desired.trim();
    let base = if base.is_empty() { "work" } else { base };
    let mut candidate = base.to_string();
    let mut n = 2;
    while branch_exists(project, &candidate)? {
        candidate = format!("{base}-{n}");
        n += 1;
    }
    Ok(candidate)
}

fn branch_exists(project: &Project, branch: &str) -> Result<bool> {
    let status = Command::new("git")
        .arg("-C")
        .arg(&project.root)
        .args([
            "show-ref",
            "--verify",
            "--quiet",
            &format!("refs/heads/{branch}"),
        ])
        .status()?;
    Ok(status.success())
}

/// rsync untracked files (e.g. `.envrc`, secrets) from the repo root into the new
/// worktree, excluding `.git` and the worktrees root itself.
fn rsync_untracked(project: &Project, root_rel: &str, dest: &Path) -> Result<()> {
    // The top-level component of the worktrees root, e.g. `.agent-sandbox`.
    let exclude_top = root_rel.split('/').next().unwrap_or(root_rel);
    let src = format!("{}/", project.root.display());
    let dst = format!("{}/", dest.display());

    let status = Command::new("rsync")
        .args([
            "-a",
            "--exclude",
            ".git",
            "--exclude",
            exclude_top,
            "--ignore-existing",
            &src,
            &dst,
        ])
        .status()
        .context("spawning rsync")?;
    if !status.success() {
        anyhow::bail!("rsync exited non-zero");
    }
    Ok(())
}

fn run_restrict_hook(worktree: &Path, hook_rel: &str, warnings: &mut Vec<String>) {
    let hook = worktree.join(hook_rel);
    if !hook.exists() {
        return;
    }
    let is_exec = is_executable(&hook);
    if !is_exec {
        warnings.push(format!(
            "{hook_rel} exists but is not executable; skipping",
        ));
        return;
    }
    match Command::new(&hook).current_dir(worktree).status() {
        Ok(s) if s.success() => {}
        Ok(s) => warnings.push(format!("{hook_rel} exited with {s}")),
        Err(e) => warnings.push(format!("failed to run {hook_rel}: {e}")),
    }
}

#[cfg(unix)]
fn is_executable(path: &Path) -> bool {
    use std::os::unix::fs::PermissionsExt;
    std::fs::metadata(path)
        .map(|m| m.permissions().mode() & 0o111 != 0)
        .unwrap_or(false)
}

#[cfg(not(unix))]
fn is_executable(_path: &Path) -> bool {
    true
}

/// Best-effort ownership change. Skips silently if the target user/group don't
/// exist; tries non-interactive sudo so the TUI is never blocked on a password.
fn chown_best_effort(path: &Path, user: &str, group: &str, warnings: &mut Vec<String>) {
    if !user_exists(user) || !group_exists(group) {
        warnings.push(format!(
            "user/group {user}:{group} not present; left worktree owned by current user"
        ));
        return;
    }
    let spec = format!("{user}:{group}");
    let status = Command::new("sudo")
        .args(["-n", "chown", "-R", &spec])
        .arg(path)
        .status();
    match status {
        Ok(s) if s.success() => {}
        _ => warnings.push(format!(
            "could not chown to {spec} (needs sudo); container isolation still applies"
        )),
    }
}

fn user_exists(user: &str) -> bool {
    Command::new("id")
        .arg(user)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn group_exists(group: &str) -> bool {
    // Works on macOS (dscl) and Linux (getent). Fall back to true-ish probing.
    if Command::new("getent")
        .args(["group", group])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
    {
        return true;
    }
    Command::new("dscl")
        .args([".", "-read", &format!("/Groups/{group}")])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}
