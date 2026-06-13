//! The only module that shells out to `docker`. Everything else builds argument
//! specs and calls in here.

mod run;

pub use run::{Mount, RunSpec};

use crate::error::{Result, SandboxError};
use anyhow::Context;
use std::process::{Command, Stdio};

/// True if the docker CLI is present and the daemon is reachable.
pub fn is_available() -> bool {
    Command::new("docker")
        .args(["version", "--format", "{{.Server.Version}}"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Run `docker <args>` and capture stdout. Errors if docker is missing or the
/// command exits non-zero.
pub fn run_capture(args: &[&str]) -> Result<String> {
    let out = Command::new("docker")
        .args(args)
        .output()
        .map_err(|_| SandboxError::DockerUnavailable)?;
    if !out.status.success() {
        anyhow::bail!(
            "docker {} failed: {}",
            args.join(" "),
            String::from_utf8_lossy(&out.stderr).trim()
        );
    }
    Ok(String::from_utf8_lossy(&out.stdout).to_string())
}

/// Run `docker <args>` with inherited stdout/stderr (for build output), waiting
/// for completion.
pub fn run_streaming(args: &[&str]) -> Result<()> {
    let status = Command::new("docker")
        .args(args)
        .stdin(Stdio::null())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .context("spawning docker")?;
    if !status.success() {
        anyhow::bail!("docker {} exited with {}", args.join(" "), status);
    }
    Ok(())
}

/// Run `docker <args>` with the full terminal handed over (interactive shell).
/// The caller MUST tear down any TUI before calling this. Returns the child's
/// exit code (0 if it can't be determined).
pub fn exec_interactive(args: &[String]) -> Result<i32> {
    let status = Command::new("docker")
        .args(args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .context("spawning interactive docker")?;
    Ok(status.code().unwrap_or(0))
}
