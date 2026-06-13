//! Serde schema for `.agent-sandbox/config` (YAML).
//!
//! Every field defaults so an empty file is valid; `deny_unknown_fields` catches
//! typos. Fields tagged "deferred" below are part of the designed schema but are
//! not yet wired into the launch path (compose overlays, mitmproxy, dc layers,
//! inference). They round-trip through (de)serialization today.

use indexmap::IndexMap;
use serde::{Deserialize, Serialize};

fn default_version() -> u32 {
    1
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct SandboxConfig {
    pub version: u32,
    pub name: Option<String>,
    /// App slugs (elixir/node/rust/claude/codex/opencode/shell...).
    pub apps: Vec<String>,
    /// Whether the container may reach the public internet. Default false (safe).
    pub internet_access: bool,
    pub agent: AgentConfig,
    /// Environment variables injected into the container, in declared order.
    pub env: IndexMap<String, EnvValue>,
    /// direnv-config layers to materialize into env (deferred).
    pub dc: DcConfig,
    pub ports: Vec<PortMapping>,
    pub mounts: Vec<MountSpec>,
    pub hooks: Hooks,
    /// docker-compose base + per-worktree overlay (deferred).
    pub compose: ComposeConfig,
    pub tools: ToolsConfig,
    pub worktree: WorktreeConfig,
    pub image: ImageOverrides,
}

impl Default for SandboxConfig {
    fn default() -> Self {
        Self {
            version: default_version(),
            name: None,
            apps: Vec::new(),
            internet_access: false,
            agent: AgentConfig::default(),
            env: IndexMap::new(),
            dc: DcConfig::default(),
            ports: Vec::new(),
            mounts: Vec::new(),
            hooks: Hooks::default(),
            compose: ComposeConfig::default(),
            tools: ToolsConfig::default(),
            worktree: WorktreeConfig::default(),
            image: ImageOverrides::default(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct AgentConfig {
    /// Agent launched as the run command: claude | codex | opencode | shell.
    pub default: String,
    /// Agents to ensure are installed in the image.
    pub available: Vec<String>,
    /// Override the in-container run command. Default: interactive login shell.
    pub run_cmd: Option<String>,
    /// Run the agent in dangerous / auto-approve mode.
    pub dangerous: bool,
}

impl Default for AgentConfig {
    fn default() -> Self {
        Self {
            default: "claude".to_string(),
            available: Vec::new(),
            run_cmd: None,
            dangerous: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum EnvValue {
    /// Literal value.
    Literal(String),
    /// Pull the value from the host environment at launch.
    FromHost { from_host: String },
    /// Resolve via a direnv-config layer (deferred).
    FromDc { dc: String },
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct DcConfig {
    pub sections: Vec<String>,
    pub envrc: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PortMapping {
    pub host: u16,
    pub container: u16,
    #[serde(default = "default_proto")]
    pub protocol: String,
    /// Host interface to bind. Defaults to loopback for safety.
    #[serde(default = "default_bind")]
    pub bind: Option<String>,
}

fn default_proto() -> String {
    "tcp".to_string()
}
fn default_bind() -> Option<String> {
    Some("127.0.0.1".to_string())
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct MountSpec {
    pub source: String,
    pub target: String,
    #[serde(default)]
    pub read_only: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Hooks {
    /// Run once on the host after a new worktree is created (deferred).
    pub init_worktree: Option<String>,
    /// Run on the host before every launch.
    pub before_launch: Option<String>,
    /// Run inside the container before the run command.
    pub on_docker_start: Option<String>,
    /// Run on the host after the container is up (deferred).
    pub post_container_start: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ComposeConfig {
    pub base_file: Option<String>,
    pub network: Option<String>,
    pub services: Vec<OutboundService>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct OutboundService {
    pub name: String,
    pub image: Option<String>,
    #[serde(default)]
    pub ports: Vec<PortMapping>,
    #[serde(default)]
    pub mitmproxy: MitmConfig,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct MitmConfig {
    pub enabled: bool,
    pub mode: MitmMode,
    pub upstream: Option<String>,
    pub listen_port: Option<u16>,
    pub log_dir: Option<String>,
    pub allow: Vec<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MitmMode {
    #[default]
    Off,
    Log,
    Intercept,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ToolsConfig {
    /// Names under `~/.local/bin` to stage into the worktree.
    pub copy_bins: Vec<String>,
    /// Names under `~/.local/share` to stage into the worktree.
    pub copy_shares: Vec<String>,
    /// Prepend the staged tool dir to PATH inside the container.
    pub prepend_path: bool,
}

impl Default for ToolsConfig {
    fn default() -> Self {
        Self {
            copy_bins: vec![
                "docker-rebuild".to_string(),
                "docker-build".to_string(),
                "docker-push".to_string(),
            ],
            copy_shares: vec!["k8-lib".to_string()],
            prepend_path: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct WorktreeConfig {
    pub root: String,
    pub owner_user: Option<String>,
    pub owner_group: Option<String>,
    pub rsync_untracked: bool,
    pub restrict_access_hook: Option<String>,
}

impl Default for WorktreeConfig {
    fn default() -> Self {
        Self {
            root: ".agent-sandbox/worktrees".to_string(),
            owner_user: Some("claude".to_string()),
            owner_group: Some("agents".to_string()),
            rsync_untracked: true,
            restrict_access_hook: Some("bin/restrict-access".to_string()),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ImageOverrides {
    /// Pin an explicit base image instead of generating from scratch.
    pub base: Option<String>,
    /// Extra snippet slugs beyond `apps`.
    pub extra_snippets: Vec<String>,
    /// Pretty registry/name prefix shown in the UI. Tags are always lowercase.
    pub registry_prefix: String,
}

impl Default for ImageOverrides {
    fn default() -> Self {
        Self {
            base: None,
            extra_snippets: Vec::new(),
            registry_prefix: "AgentSandbox".to_string(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_config_is_valid() {
        let cfg: SandboxConfig = serde_yaml::from_str("{}").unwrap();
        assert_eq!(cfg.version, 1);
        assert!(!cfg.internet_access);
        assert_eq!(cfg.agent.default, "claude");
        assert!(cfg.agent.dangerous);
        assert!(cfg.tools.prepend_path);
    }

    #[test]
    fn env_value_variants_parse() {
        let yaml = r#"
env:
  LITERAL: hello
  HOSTED:
    from_host: HOME
  LAYERED:
    dc: cluster.kubeconfig
"#;
        let cfg: SandboxConfig = serde_yaml::from_str(yaml).unwrap();
        assert!(matches!(cfg.env["LITERAL"], EnvValue::Literal(_)));
        assert!(matches!(cfg.env["HOSTED"], EnvValue::FromHost { .. }));
        assert!(matches!(cfg.env["LAYERED"], EnvValue::FromDc { .. }));
    }

    #[test]
    fn unknown_field_is_rejected() {
        let err = serde_yaml::from_str::<SandboxConfig>("bogus_field: 1");
        assert!(err.is_err());
    }

    #[test]
    fn port_defaults() {
        let yaml = "ports:\n  - { host: 8080, container: 80 }\n";
        let cfg: SandboxConfig = serde_yaml::from_str(yaml).unwrap();
        assert_eq!(cfg.ports[0].protocol, "tcp");
        assert_eq!(cfg.ports[0].bind.as_deref(), Some("127.0.0.1"));
    }

    #[test]
    fn roundtrip_full_config() {
        let yaml = r#"
name: demo
apps: [node, rust]
internet_access: true
agent:
  default: claude
  available: [claude, codex]
ports:
  - { host: 3000, container: 3000 }
compose:
  network: agent-sandbox
  services:
    - name: redis
      image: redis:7
      mitmproxy:
        enabled: true
        mode: log
        upstream: redis:6379
        listen_port: 6380
"#;
        let cfg: SandboxConfig = serde_yaml::from_str(yaml).unwrap();
        assert_eq!(cfg.apps, vec!["node", "rust"]);
        assert_eq!(cfg.compose.services[0].mitmproxy.mode, MitmMode::Log);
        // ensure it serializes back without error
        let out = serde_yaml::to_string(&cfg).unwrap();
        let _re: SandboxConfig = serde_yaml::from_str(&out).unwrap();
    }
}
