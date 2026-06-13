//! Static fixture data for the `preview` subcommand and tests.
//!
//! Provides realistic-looking sandbox objects without requiring a git repo,
//! docker daemon, or network inference service.

use crate::config::SandboxConfig;
use crate::image::{AppSet, ImagePlan, PlanKind};
use crate::worktree::{Status, Worktree};
use std::path::PathBuf;

pub const FIXTURE_SNIPPETS: &[&str] = &["claude", "codex", "node", "rust", "elixir", "shell"];

pub fn fixture_config() -> SandboxConfig {
    let mut cfg = SandboxConfig::default();
    cfg.name = Some("demo-project".to_string());
    cfg.apps = vec!["node".to_string(), "rust".to_string()];
    cfg.internet_access = false;
    cfg
}

pub fn fixture_worktrees() -> Vec<Worktree> {
    let base = PathBuf::from("/demo/project/.agent-sandbox/worktrees");
    vec![
        Worktree {
            path: base.join("main"),
            branch: "main".to_string(),
            head: "a1b2c3d4".to_string(),
            status: Status { staged: 0, modified: 0, untracked: 0, ahead: 0, behind: 0 },
        },
        Worktree {
            path: base.join("feat-api-refactor"),
            branch: "feat/api-refactor".to_string(),
            head: "e5f6a7b8".to_string(),
            status: Status { staged: 2, modified: 3, untracked: 1, ahead: 4, behind: 0 },
        },
        Worktree {
            path: base.join("fix-auth-token-expiry"),
            branch: "fix/auth-token-expiry".to_string(),
            head: "c9d0e1f2".to_string(),
            status: Status { staged: 0, modified: 1, untracked: 0, ahead: 0, behind: 2 },
        },
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fixture_config_is_valid() {
        let cfg = fixture_config();
        assert!(cfg.name.is_some());
        assert!(!cfg.apps.is_empty());
    }

    #[test]
    fn fixture_worktrees_non_empty_slugs() {
        let wts = fixture_worktrees();
        assert!(!wts.is_empty());
        for wt in &wts {
            assert!(!wt.slug().is_empty());
        }
    }

    #[test]
    fn fixture_plan_summary_non_empty() {
        assert!(!fixture_plan().summary().is_empty());
    }
}

pub fn fixture_plan() -> ImagePlan {
    ImagePlan {
        requested: AppSet::from_slugs(&["node", "rust"]),
        kind: PlanKind::Exact {
            reference: "agent-sandbox:node-rust".to_string(),
        },
        pretty_prefix: "AgentSandbox".to_string(),
    }
}
