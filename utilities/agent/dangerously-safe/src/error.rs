//! Shared error types. Most code uses `anyhow::Result`; domain-specific failures
//! that callers may want to match on live in [`SandboxError`].

use thiserror::Error;

/// Convenience alias used throughout the crate.
pub type Result<T> = anyhow::Result<T>;

#[derive(Debug, Error)]
pub enum SandboxError {
    #[error("not inside a git repository (run `agent-sandbox` from within a repo)")]
    NotAGitRepo,

    #[error("docker is not available on PATH or the daemon is not running")]
    DockerUnavailable,

    #[error("unknown app snippet: {0}")]
    UnknownSnippet(String),

    #[error("snippet dependency cycle detected involving: {0}")]
    SnippetCycle(String),

    #[error("no app snippets requested; cannot build an image with an empty app set")]
    EmptyAppSet,
}
