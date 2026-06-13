//! Git worktree discovery and creation under `.agent-sandbox/worktrees`.

mod create;
mod status;

pub use create::create_worktree;
pub use status::Status;

use crate::config::Project;
use crate::error::Result;
use std::path::PathBuf;
use std::process::Command;

/// A worktree managed by agent-sandbox, with its current status.
#[derive(Debug, Clone)]
pub struct Worktree {
    pub path: PathBuf,
    pub branch: String,
    /// The worktree's HEAD commit (kept for display/debugging).
    #[allow(dead_code)]
    pub head: String,
    pub status: Status,
}

impl Worktree {
    /// Directory name (the branch slug).
    pub fn slug(&self) -> String {
        self.path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("")
            .to_string()
    }
}

/// Absolute path to the worktrees root for a project, honoring config override.
pub fn worktrees_root(project: &Project, root_rel: &str) -> PathBuf {
    project.root.join(root_rel)
}

/// Parse git porcelain worktree output into (path, head, branch) tuples.
fn parse_worktree_porcelain(text: &str) -> Vec<(PathBuf, String, String)> {
    let mut entries: Vec<(PathBuf, String, String)> = Vec::new();
    let mut cur: Option<(PathBuf, String, String)> = None;

    for line in text.lines() {
        if let Some(p) = line.strip_prefix("worktree ") {
            if let Some(prev) = cur.take() {
                entries.push(prev);
            }
            cur = Some((PathBuf::from(p.trim()), String::new(), String::new()));
        } else if let Some(h) = line.strip_prefix("HEAD ") {
            if let Some(ref mut c) = cur {
                c.1 = h.trim().to_string();
            }
        } else if let Some(b) = line.strip_prefix("branch ") {
            if let Some(ref mut c) = cur {
                c.2 = b.trim().trim_start_matches("refs/heads/").to_string();
            }
        }
    }
    if let Some(last) = cur {
        entries.push(last);
    }
    entries
}

/// List managed worktrees (those living under the configured worktrees root).
pub fn list_worktrees(project: &Project, root_rel: &str) -> Result<Vec<Worktree>> {
    let root = worktrees_root(project, root_rel);
    let out = Command::new("git")
        .arg("-C")
        .arg(&project.root)
        .args(["worktree", "list", "--porcelain"])
        .output()?;
    let text = String::from_utf8_lossy(&out.stdout);

    let mut worktrees: Vec<Worktree> = parse_worktree_porcelain(&text)
        .into_iter()
        .filter(|(p, _, _)| p.starts_with(&root))
        .map(|(p, head, branch)| {
            let st = status::status_for(&p).unwrap_or_default();
            Worktree { path: p, branch, head, status: st }
        })
        .collect();

    worktrees.sort_by_key(|a| a.slug());
    Ok(worktrees)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_empty_input() {
        assert!(parse_worktree_porcelain("").is_empty());
    }

    #[test]
    fn parse_single_worktree() {
        let input = "worktree /repo/main\nHEAD abc123\nbranch refs/heads/main\n";
        let entries = parse_worktree_porcelain(input);
        assert_eq!(entries.len(), 1);
        assert_eq!(entries[0].0, PathBuf::from("/repo/main"));
        assert_eq!(entries[0].1, "abc123");
        assert_eq!(entries[0].2, "main");
    }

    #[test]
    fn parse_multiple_worktrees() {
        let input = concat!(
            "worktree /repo/main\nHEAD aaa\nbranch refs/heads/main\n",
            "worktree /repo/.agent-sandbox/worktrees/feat-1\nHEAD bbb\nbranch refs/heads/feat-1\n"
        );
        let entries = parse_worktree_porcelain(input);
        assert_eq!(entries.len(), 2);
        assert_eq!(entries[1].2, "feat-1");
    }

    #[test]
    fn slug_returns_directory_name() {
        let wt = Worktree {
            path: PathBuf::from("/repo/.agent-sandbox/worktrees/my-feature"),
            branch: "my-feature".to_string(),
            head: "deadbeef".to_string(),
            status: status::Status::default(),
        };
        assert_eq!(wt.slug(), "my-feature");
    }
}

/// The current branch of the project repo (the default origin for new worktrees).
pub fn current_branch(project: &Project) -> Result<String> {
    let out = Command::new("git")
        .arg("-C")
        .arg(&project.root)
        .args(["branch", "--show-current"])
        .output()?;
    Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
}
