//! Git status summaries for a worktree.

use crate::error::Result;
use std::path::Path;
use std::process::Command;

/// Working-tree state of a worktree.
#[derive(Debug, Clone, Default)]
pub struct Status {
    pub staged: usize,
    pub modified: usize,
    pub untracked: usize,
    pub ahead: usize,
    pub behind: usize,
}

impl Status {
    /// Compact one-line summary for the picker, e.g. `↑2 ↓0 ●3 +1 ?4`.
    pub fn summary(&self) -> String {
        let mut parts = Vec::new();
        if self.ahead > 0 || self.behind > 0 {
            parts.push(format!("↑{} ↓{}", self.ahead, self.behind));
        }
        if self.staged > 0 {
            parts.push(format!("+{}", self.staged));
        }
        if self.modified > 0 {
            parts.push(format!("●{}", self.modified));
        }
        if self.untracked > 0 {
            parts.push(format!("?{}", self.untracked));
        }
        if parts.is_empty() {
            "clean".to_string()
        } else {
            parts.join(" ")
        }
    }
}

fn git(path: &Path, args: &[&str]) -> Result<String> {
    let out = Command::new("git")
        .arg("-C")
        .arg(path)
        .args(args)
        .output()?;
    Ok(String::from_utf8_lossy(&out.stdout).to_string())
}

/// Collect the working-tree status for `path`.
pub fn status_for(path: &Path) -> Result<Status> {
    let mut st = Status::default();

    // Porcelain v1: first two columns are XY status codes.
    let porcelain = git(path, &["status", "--porcelain"])?;
    for line in porcelain.lines() {
        if line.len() < 2 {
            continue;
        }
        let bytes = line.as_bytes();
        let (x, y) = (bytes[0] as char, bytes[1] as char);
        if x == '?' && y == '?' {
            st.untracked += 1;
            continue;
        }
        if x != ' ' && x != '?' {
            st.staged += 1;
        }
        if y != ' ' && y != '?' {
            st.modified += 1;
        }
    }

    // Ahead/behind vs upstream, if one is configured.
    let counts = git(
        path,
        &["rev-list", "--left-right", "--count", "@{upstream}...HEAD"],
    )
    .unwrap_or_default();
    if let Some((behind, ahead)) = counts.split_once(char::is_whitespace) {
        st.behind = behind.trim().parse().unwrap_or(0);
        st.ahead = ahead.trim().parse().unwrap_or(0);
    }

    Ok(st)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn st(staged: usize, modified: usize, untracked: usize, ahead: usize, behind: usize) -> Status {
        Status { staged, modified, untracked, ahead, behind }
    }

    #[test]
    fn clean_when_all_zero() {
        assert_eq!(st(0, 0, 0, 0, 0).summary(), "clean");
    }

    #[test]
    fn shows_all_nonzero_fields() {
        let s = st(1, 2, 3, 4, 5).summary();
        assert!(s.contains("↑4 ↓5"));
        assert!(s.contains("+1"));
        assert!(s.contains("●2"));
        assert!(s.contains("?3"));
    }

    #[test]
    fn staged_only() {
        assert_eq!(st(2, 0, 0, 0, 0).summary(), "+2");
    }

    #[test]
    fn ahead_behind_only() {
        let s = st(0, 0, 0, 1, 0).summary();
        assert!(s.starts_with("↑1 ↓0"));
    }
}
