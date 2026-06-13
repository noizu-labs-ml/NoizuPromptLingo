//! Pure generation of a per-worktree docker-compose overlay: the interactive
//! `agent` service, any outbound services, and mitmproxy log sidecars. All join
//! a shared external network so the agent can reach infra by service name.

use crate::config::{MitmMode, OutboundService, PortMapping};
use indexmap::IndexMap;
use serde::Serialize;
use std::path::Path;

/// The interactive agent container, derived from the launch spec.
#[derive(Debug, Clone)]
pub struct AgentService {
    pub image: String,
    pub container_name: String,
    pub working_dir: String,
    pub volumes: Vec<String>,
    pub environment: IndexMap<String, String>,
    pub ports: Vec<String>,
    pub entrypoint: Option<String>,
    pub command: Vec<String>,
}

#[derive(Debug, Serialize)]
struct ComposeFile {
    services: IndexMap<String, Service>,
    networks: IndexMap<String, Network>,
}

#[derive(Debug, Default, Serialize)]
struct Service {
    image: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    container_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    working_dir: Option<String>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    volumes: Vec<String>,
    #[serde(skip_serializing_if = "IndexMap::is_empty")]
    environment: IndexMap<String, String>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    ports: Vec<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    entrypoint: Option<String>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    command: Vec<String>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    depends_on: Vec<String>,
    networks: Vec<String>,
    #[serde(skip_serializing_if = "std::ops::Not::not")]
    tty: bool,
    #[serde(skip_serializing_if = "std::ops::Not::not")]
    stdin_open: bool,
}

#[derive(Debug, Serialize)]
struct Network {
    external: bool,
}

fn port_string(p: &PortMapping) -> String {
    match &p.bind {
        Some(addr) => format!("{}:{}:{}/{}", addr, p.host, p.container, p.protocol),
        None => format!("{}:{}/{}", p.host, p.container, p.protocol),
    }
}

/// Build the overlay YAML and any non-fatal warnings.
pub fn generate_overlay(
    agent: &AgentService,
    services: &[OutboundService],
    network: &str,
    worktree: &Path,
) -> (String, Vec<String>) {
    let mut warnings = Vec::new();
    let mut svcs: IndexMap<String, Service> = IndexMap::new();
    let mut depends: Vec<String> = Vec::new();

    for out in services {
        // The real outbound service, if an image is provided.
        if let Some(image) = &out.image {
            svcs.insert(
                out.name.clone(),
                Service {
                    image: image.clone(),
                    ports: out.ports.iter().map(port_string).collect(),
                    networks: vec![network.to_string()],
                    ..Default::default()
                },
            );
            depends.push(out.name.clone());
        }

        // mitmproxy log sidecar.
        if out.mitmproxy.enabled && out.mitmproxy.mode == MitmMode::Log {
            let Some(listen) = out.mitmproxy.listen_port else {
                warnings.push(format!(
                    "service `{}`: mitmproxy enabled but no listen_port; skipping sidecar",
                    out.name
                ));
                continue;
            };
            let Some(upstream) = &out.mitmproxy.upstream else {
                warnings.push(format!(
                    "service `{}`: mitmproxy enabled but no upstream; skipping sidecar",
                    out.name
                ));
                continue;
            };
            let log_dir = out
                .mitmproxy
                .log_dir
                .clone()
                .unwrap_or_else(|| {
                    worktree
                        .join(format!(".agent-sandbox/mitm/{}", out.name))
                        .to_string_lossy()
                        .to_string()
                });
            let mitm_name = format!("{}-mitm", out.name);
            svcs.insert(
                mitm_name.clone(),
                Service {
                    image: "mitmproxy/mitmproxy".to_string(),
                    command: vec![
                        "mitmdump".into(),
                        "--mode".into(),
                        format!("reverse:{upstream}"),
                        "--listen-host".into(),
                        "0.0.0.0".into(),
                        "--listen-port".into(),
                        listen.to_string(),
                        "-w".into(),
                        format!("/flows/{}.flow", out.name),
                    ],
                    volumes: vec![format!("{log_dir}:/flows")],
                    // The sidecar is reached over the shared network by the agent;
                    // no host port publishing needed.
                    networks: vec![network.to_string()],
                    ..Default::default()
                },
            );
            depends.push(mitm_name);
        }
    }

    depends.sort();
    svcs.insert(
        "agent".to_string(),
        Service {
            image: agent.image.clone(),
            container_name: Some(agent.container_name.clone()),
            working_dir: Some(agent.working_dir.clone()),
            volumes: agent.volumes.clone(),
            environment: agent.environment.clone(),
            ports: agent.ports.clone(),
            entrypoint: agent.entrypoint.clone(),
            command: agent.command.clone(),
            depends_on: depends,
            networks: vec![network.to_string()],
            tty: true,
            stdin_open: true,
        },
    );

    let mut networks = IndexMap::new();
    networks.insert(network.to_string(), Network { external: true });

    let file = ComposeFile {
        services: svcs,
        networks,
    };
    let yaml = serde_yaml::to_string(&file).unwrap_or_default();
    (yaml, warnings)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::MitmConfig;

    fn agent() -> AgentService {
        let mut env = IndexMap::new();
        env.insert("AGENT_SANDBOX".into(), "1".into());
        AgentService {
            image: "agent-sandbox:node".into(),
            container_name: "as-demo-feature".into(),
            working_dir: "/work".into(),
            volumes: vec!["/host/wt:/work".into()],
            environment: env,
            ports: vec!["127.0.0.1:3000:3000/tcp".into()],
            entrypoint: Some("bash".into()),
            command: vec!["-lc".into(), "exec bash -l".into()],
        }
    }

    #[test]
    fn agent_only_overlay() {
        let (yaml, warns) = generate_overlay(&agent(), &[], "agent-sandbox", Path::new("/host/wt"));
        assert!(warns.is_empty());
        assert!(yaml.contains("agent:"));
        assert!(yaml.contains("image: agent-sandbox:node"));
        assert!(yaml.contains("tty: true"));
        assert!(yaml.contains("stdin_open: true"));
        assert!(yaml.contains("external: true"));
    }

    #[test]
    fn outbound_with_mitm_log() {
        let svc = OutboundService {
            name: "redis".into(),
            image: Some("redis:7".into()),
            ports: vec![],
            mitmproxy: MitmConfig {
                enabled: true,
                mode: MitmMode::Log,
                upstream: Some("redis:6379".into()),
                listen_port: Some(6380),
                log_dir: None,
                allow: vec![],
            },
        };
        let (yaml, warns) =
            generate_overlay(&agent(), &[svc], "agent-sandbox", Path::new("/host/wt"));
        assert!(warns.is_empty());
        assert!(yaml.contains("redis:"));
        assert!(yaml.contains("image: redis:7"));
        assert!(yaml.contains("redis-mitm:"));
        assert!(yaml.contains("reverse:redis:6379"));
        assert!(yaml.contains("/flows/redis.flow"));
        // agent depends on both the service and its mitm sidecar
        assert!(yaml.contains("- redis"));
        assert!(yaml.contains("- redis-mitm"));
    }

    #[test]
    fn mitm_without_listen_port_warns() {
        let svc = OutboundService {
            name: "api".into(),
            image: None,
            ports: vec![],
            mitmproxy: MitmConfig {
                enabled: true,
                mode: MitmMode::Log,
                upstream: Some("api:80".into()),
                listen_port: None,
                log_dir: None,
                allow: vec![],
            },
        };
        let (_, warns) = generate_overlay(&agent(), &[svc], "agent-sandbox", Path::new("/wt"));
        assert_eq!(warns.len(), 1);
        assert!(warns[0].contains("listen_port"));
    }
}
