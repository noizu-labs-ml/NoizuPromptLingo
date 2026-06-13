//! docker-compose path: a shared external network, an optional shared infra base
//! file, and a generated per-worktree overlay (agent + outbound services + mitm
//! sidecars). Used instead of plain `docker run` when the config defines compose
//! services, a base file, or a network.

mod overlay;

use crate::config::SandboxConfig;
use crate::docker::{self, RunSpec};
use crate::error::Result;
use anyhow::Context;
use indexmap::IndexMap;
use overlay::{generate_overlay, AgentService};
use std::path::Path;

/// Default shared network name.
const DEFAULT_NETWORK: &str = "agent-sandbox";

/// Whether the compose path should be used for this config.
pub fn is_enabled(cfg: &SandboxConfig) -> bool {
    !cfg.compose.services.is_empty()
        || cfg.compose.base_file.is_some()
        || cfg.compose.network.is_some()
}

fn network_name(cfg: &SandboxConfig) -> String {
    cfg.compose
        .network
        .clone()
        .unwrap_or_else(|| DEFAULT_NETWORK.to_string())
}

/// Generate the overlay, ensure infra is up, and run the agent interactively.
/// Returns the agent container's exit code.
pub fn run_interactive(cfg: &SandboxConfig, spec: &RunSpec, worktree: &Path) -> Result<i32> {
    let net = network_name(cfg);
    ensure_network(&net)?;

    if let Some(base) = &cfg.compose.base_file {
        if Path::new(base).exists() {
            ensure_base(base)?;
        } else {
            eprintln!("warning: compose base_file `{base}` not found; skipping infra up");
        }
    }

    let (yaml, warnings) =
        generate_overlay(&agent_service(spec), &cfg.compose.services, &net, worktree);
    for w in warnings {
        eprintln!("warning: {w}");
    }

    let overlay_path = worktree.join(".agent-sandbox/compose.overlay.yaml");
    if let Some(parent) = overlay_path.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("creating {}", parent.display()))?;
    }
    std::fs::write(&overlay_path, yaml)
        .with_context(|| format!("writing {}", overlay_path.display()))?;

    let project = format!("as-{}", sanitize(&basename(worktree)));
    println!("compose project {project} (network {net})");

    let args = vec![
        "compose".to_string(),
        "-p".to_string(),
        project,
        "-f".to_string(),
        overlay_path.to_string_lossy().to_string(),
        "run".to_string(),
        "--rm".to_string(),
        "--service-ports".to_string(),
        "agent".to_string(),
    ];
    docker::exec_interactive(&args)
}

/// Build the agent compose service from the launch spec.
fn agent_service(spec: &RunSpec) -> AgentService {
    let volumes = spec
        .mounts
        .iter()
        .map(|m| {
            let ro = if m.read_only { ":ro" } else { "" };
            format!("{}:{}{}", m.source, m.target, ro)
        })
        .collect();

    let mut environment = IndexMap::new();
    for (k, v) in &spec.env {
        environment.insert(k.clone(), v.clone());
    }

    let ports = spec
        .ports
        .iter()
        .map(|(host, container, proto, bind)| match bind {
            Some(addr) => format!("{addr}:{host}:{container}/{proto}"),
            None => format!("{host}:{container}/{proto}"),
        })
        .collect();

    AgentService {
        image: spec.image.clone(),
        container_name: spec.name.clone(),
        working_dir: spec.workdir.clone(),
        volumes,
        environment,
        ports,
        entrypoint: spec.entrypoint.clone(),
        command: spec.command.clone(),
    }
}

/// Create the shared network if it doesn't already exist.
fn ensure_network(name: &str) -> Result<()> {
    if docker::run_capture(&["network", "inspect", name]).is_ok() {
        return Ok(());
    }
    docker::run_streaming(&["network", "create", name])
        .with_context(|| format!("creating network {name}"))
}

/// Bring up the shared infra base (idempotent).
fn ensure_base(base_file: &str) -> Result<()> {
    docker::run_streaming(&[
        "compose",
        "-p",
        "agent-sandbox-infra",
        "-f",
        base_file,
        "up",
        "-d",
    ])
    .context("bringing up compose base")
}

fn basename(p: &Path) -> String {
    p.file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("worktree")
        .to_string()
}

fn sanitize(s: &str) -> String {
    s.chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '-' || c == '_' {
                c.to_ascii_lowercase()
            } else {
                '-'
            }
        })
        .collect()
}
