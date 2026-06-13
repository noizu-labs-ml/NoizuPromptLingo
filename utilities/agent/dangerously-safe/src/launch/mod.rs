//! Launch orchestration: run host hooks, stage tools, assemble the container
//! invocation, and hand the terminal to an interactive `docker run`.
//!
//! Callers MUST tear down any TUI before invoking [`prepare_and_run`]; it hands
//! the real terminal to docker.

mod env;
mod hooks;
mod tools;

use crate::config::SandboxConfig;
use crate::docker::{self, Mount, RunSpec};
use crate::error::Result;
use crate::paths;
use std::path::{Path, PathBuf};

/// Everything needed to launch a sandbox.
#[derive(Debug, Clone)]
pub struct LaunchRequest {
    pub project_root: PathBuf,
    pub worktree: PathBuf,
    pub image: String,
    pub cfg: SandboxConfig,
    pub is_new_worktree: bool,
}

/// Run host hooks, stage tools, and exec the interactive container. Returns the
/// container's exit code.
pub fn prepare_and_run(req: &LaunchRequest) -> Result<i32> {
    let cfg = &req.cfg;
    let host_env = env::host_hook_env(&req.worktree);

    // 1. init-worktree hook (host) on first creation.
    if req.is_new_worktree {
        if let Some(hook) = &cfg.hooks.init_worktree {
            hooks::run_host_hook(&req.worktree, hook, &host_env, "init-worktree")?;
        }
    }

    // 2. before-launch hook (host), every launch.
    if let Some(hook) = &cfg.hooks.before_launch {
        hooks::run_host_hook(&req.worktree, hook, &host_env, "before-launch")?;
    }

    // 3. stage internal tools into the worktree.
    let warnings = tools::stage_tools(&cfg.tools, &req.worktree);

    // 4. container env.
    let project_name = cfg
        .name
        .clone()
        .unwrap_or_else(|| basename(&req.project_root));
    let (container_env, env_warnings) = env::container_env(cfg, &project_name);

    // 5. mounts.
    let mounts = build_mounts(cfg, &req.worktree);

    // 6. ports.
    let ports = cfg
        .ports
        .iter()
        .map(|p| (p.host, p.container, p.protocol.clone(), p.bind.clone()))
        .collect();

    // 7. in-container script: PATH prepend, on-docker-start hook, exec run cmd.
    let script = build_container_script(cfg);

    let spec = RunSpec {
        image: req.image.clone(),
        name: container_name(&project_name, &req.worktree),
        workdir: env::CONTAINER_WORKDIR.to_string(),
        mounts,
        env: container_env,
        ports,
        network: cfg.compose.network.clone(),
        internet_access: cfg.internet_access,
        remove: true,
        entrypoint: Some("bash".to_string()),
        command: vec!["-lc".to_string(), script],
    };

    // Surface warnings before handing over the terminal.
    for w in warnings.into_iter().chain(env_warnings) {
        eprintln!("warning: {w}");
    }
    println!("launching {} in {}", req.image, req.worktree.display());

    // Use docker-compose when the config defines services/base/network; this
    // gives the agent a shared network with infra and optional mitm sidecars.
    // Otherwise fall back to a plain isolated `docker run`.
    if crate::compose::is_enabled(cfg) {
        crate::compose::run_interactive(cfg, &spec, &req.worktree)
    } else {
        if !cfg.internet_access {
            println!("(network: isolated — internet access disabled)");
        }
        docker::exec_interactive(&spec.to_args())
    }
}

/// Default mounts: worktree -> /work, plus agent credential dirs for each agent.
fn build_mounts(cfg: &SandboxConfig, worktree: &Path) -> Vec<Mount> {
    let mut mounts = vec![Mount {
        source: worktree.to_string_lossy().to_string(),
        target: env::CONTAINER_WORKDIR.to_string(),
        read_only: false,
    }];

    let mut agents: Vec<String> = cfg.agent.available.clone();
    agents.push(cfg.agent.default.clone());
    agents.sort();
    agents.dedup();

    for agent in agents {
        if let Some((host_rel, container)) = agent_home(&agent) {
            let src = paths::home().join(host_rel);
            if src.exists() {
                mounts.push(Mount {
                    source: src.to_string_lossy().to_string(),
                    target: container.to_string(),
                    read_only: false,
                });
            }
        }
    }

    for m in &cfg.mounts {
        mounts.push(Mount {
            source: expand_home(&m.source),
            target: m.target.clone(),
            read_only: m.read_only,
        });
    }

    mounts
}

/// Map an agent slug to its (host-relative config dir, container path). The
/// container runs as root, so credentials land under /root.
fn agent_home(agent: &str) -> Option<(&'static str, &'static str)> {
    match agent {
        "claude" => Some((".claude", "/root/.claude")),
        "codex" => Some((".codex", "/root/.codex")),
        "opencode" => Some((".config/opencode", "/root/.config/opencode")),
        _ => None,
    }
}

/// Build the `bash -lc` script run inside the container.
fn build_container_script(cfg: &SandboxConfig) -> String {
    let mut lines = Vec::new();
    if cfg.tools.prepend_path {
        lines.push(format!("export PATH={}:$PATH", tools::CONTAINER_TOOL_BIN));
    }
    if let Some(hook) = &cfg.hooks.on_docker_start {
        // hook path is relative to the worktree, mounted at /work.
        lines.push(format!("{}/{}", env::CONTAINER_WORKDIR, hook.trim_start_matches("./")));
    }
    let final_cmd = cfg
        .agent
        .run_cmd
        .clone()
        .unwrap_or_else(|| "bash -l".to_string());
    lines.push(format!("exec {final_cmd}"));
    lines.join("\n")
}

fn container_name(project: &str, worktree: &Path) -> String {
    let wt = basename(worktree);
    sanitize(&format!("as-{project}-{wt}"))
}

fn sanitize(s: &str) -> String {
    s.chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '-' || c == '_' || c == '.' {
                c
            } else {
                '-'
            }
        })
        .collect()
}

fn basename(p: &Path) -> String {
    p.file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("project")
        .to_string()
}

fn expand_home(path: &str) -> String {
    if let Some(rest) = path.strip_prefix("~/") {
        return paths::home().join(rest).to_string_lossy().to_string();
    }
    if path == "~" {
        return paths::home().to_string_lossy().to_string();
    }
    if let Some(rest) = path.strip_prefix("$HOME/") {
        return paths::home().join(rest).to_string_lossy().to_string();
    }
    path.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    #[test]
    fn sanitize_replaces_spaces_and_slashes() {
        assert_eq!(sanitize("hello world!"), "hello-world-");
        assert_eq!(sanitize("a/b"), "a-b");
    }

    #[test]
    fn sanitize_allows_safe_chars() {
        let s = "abc-123_foo.bar";
        assert_eq!(sanitize(s), s);
    }

    #[test]
    fn basename_last_segment() {
        assert_eq!(basename(Path::new("/a/b/c")), "c");
        assert_eq!(basename(Path::new("/single")), "single");
    }

    #[test]
    fn basename_root_fallback() {
        assert_eq!(basename(Path::new("/")), "project");
    }

    #[test]
    fn expand_home_tilde_slash() {
        let r = expand_home("~/foo");
        assert!(r.ends_with("/foo"));
        assert!(!r.starts_with('~'));
    }

    #[test]
    fn expand_home_dollar_home() {
        let r = expand_home("$HOME/bar");
        assert!(r.ends_with("/bar"));
        assert!(!r.starts_with("$HOME"));
    }

    #[test]
    fn expand_home_tilde_alone() {
        let r = expand_home("~");
        assert!(!r.is_empty());
        assert_ne!(r, "~");
    }

    #[test]
    fn expand_home_passthrough() {
        assert_eq!(expand_home("/abs/path"), "/abs/path");
        assert_eq!(expand_home("rel/path"), "rel/path");
    }

    #[test]
    fn agent_home_known() {
        assert!(agent_home("claude").is_some());
        assert!(agent_home("codex").is_some());
        assert!(agent_home("opencode").is_some());
    }

    #[test]
    fn agent_home_unknown_is_none() {
        assert!(agent_home("unknown-agent").is_none());
    }

    #[test]
    fn container_name_no_spaces() {
        let name = container_name("my project", Path::new("/wt/feat branch"));
        assert!(!name.contains(' '));
        assert!(name.starts_with("as-"));
    }

    #[test]
    fn build_container_script_has_exec() {
        let cfg = SandboxConfig::default();
        let script = build_container_script(&cfg);
        assert!(script.contains("exec "));
    }

    #[test]
    fn build_container_script_hook_path() {
        let mut cfg = SandboxConfig::default();
        cfg.hooks.on_docker_start = Some("./bin/start.sh".to_string());
        let script = build_container_script(&cfg);
        assert!(script.contains("/work/bin/start.sh"));
    }
}

/// Environment / dependency check for `agent-sandbox doctor`.
pub fn doctor() -> Result<()> {
    let docker_ok = docker::is_available();
    println!(
        "docker daemon: {}",
        if docker_ok { "ok" } else { "UNAVAILABLE" }
    );

    let git_ok = std::process::Command::new("git")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false);
    println!("git: {}", if git_ok { "ok" } else { "MISSING" });

    println!("\ninternal tools (~/.local/bin):");
    for tool in ["docker-rebuild", "docker-build", "docker-push"] {
        let present = paths::local_bin().join(tool).exists();
        println!("  {tool}: {}", if present { "ok" } else { "missing" });
    }
    println!("internal shares (~/.local/share):");
    let share = "k8-lib";
    let present = paths::local_share().join(share).exists();
    println!("  {share}: {}", if present { "ok" } else { "missing" });

    println!("\nsnippet search path:");
    for dir in paths::snippet_dirs() {
        println!(
            "  {} {}",
            dir.display(),
            if dir.exists() { "(present)" } else { "(absent)" }
        );
    }

    if !docker_ok {
        anyhow::bail!("docker is required but unavailable");
    }
    Ok(())
}
