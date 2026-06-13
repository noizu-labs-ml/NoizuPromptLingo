//! Assemble the environment variables injected into the sandbox container.

use crate::config::{EnvValue, SandboxConfig};
use std::path::Path;

/// Mount target of the worktree inside the container.
pub const CONTAINER_WORKDIR: &str = "/work";

/// Build the ordered container env plus any warnings (e.g. unresolved host vars).
pub fn container_env(
    cfg: &SandboxConfig,
    project_name: &str,
) -> (Vec<(String, String)>, Vec<String>) {
    let mut env = Vec::new();
    let mut warnings = Vec::new();

    // agent-sandbox markers (path is the in-container mount target).
    env.push(("AGENT_SANDBOX".into(), "1".into()));
    env.push((
        "AGENT_SANDBOX_WORKTREE_PATH".into(),
        CONTAINER_WORKDIR.into(),
    ));
    env.push(("AGENT_SANDBOX_PROJECT".into(), project_name.into()));

    for (key, val) in &cfg.env {
        match val {
            EnvValue::Literal(v) => env.push((key.clone(), v.clone())),
            EnvValue::FromHost { from_host } => match std::env::var(from_host) {
                Ok(v) => env.push((key.clone(), v)),
                Err(_) => warnings.push(format!(
                    "env {key}: host variable ${from_host} is unset; skipped"
                )),
            },
            EnvValue::FromDc { dc } => {
                warnings.push(format!("env {key}: dc layer `{dc}` not yet supported; skipped"));
            }
        }
    }

    (env, warnings)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::{EnvValue, SandboxConfig};
    use indexmap::IndexMap;

    #[test]
    fn required_markers_present() {
        let (env, warnings) = container_env(&SandboxConfig::default(), "myproject");
        let keys: Vec<&str> = env.iter().map(|(k, _)| k.as_str()).collect();
        assert!(keys.contains(&"AGENT_SANDBOX"));
        assert!(keys.contains(&"AGENT_SANDBOX_WORKTREE_PATH"));
        assert!(keys.contains(&"AGENT_SANDBOX_PROJECT"));
        assert!(warnings.is_empty());
    }

    #[test]
    fn project_name_forwarded() {
        let (env, _) = container_env(&SandboxConfig::default(), "my-proj");
        let val = env.iter().find(|(k, _)| k == "AGENT_SANDBOX_PROJECT").unwrap();
        assert_eq!(val.1, "my-proj");
    }

    #[test]
    fn literal_env_value() {
        let mut cfg = SandboxConfig::default();
        cfg.env = IndexMap::from([("FOO".to_string(), EnvValue::Literal("bar".to_string()))]);
        let (env, warnings) = container_env(&cfg, "p");
        let val = env.iter().find(|(k, _)| k == "FOO").unwrap();
        assert_eq!(val.1, "bar");
        assert!(warnings.is_empty());
    }

    #[test]
    fn missing_host_var_produces_warning() {
        let mut cfg = SandboxConfig::default();
        cfg.env = IndexMap::from([(
            "MISSING".to_string(),
            EnvValue::FromHost { from_host: "__SANDBOX_TEST_UNSET_XYZ__".to_string() },
        )]);
        let (_, warnings) = container_env(&cfg, "p");
        assert!(!warnings.is_empty());
        assert!(warnings[0].contains("MISSING"));
    }
}

/// Host env for before-launch hooks: exposes the real worktree path on the host.
pub fn host_hook_env(worktree: &Path) -> Vec<(String, String)> {
    let real = std::fs::canonicalize(worktree).unwrap_or_else(|_| worktree.to_path_buf());
    vec![
        ("AGENT_SANDBOX".into(), "1".into()),
        (
            "AGENT_SANDBOX_WORKTREE_PATH".into(),
            real.to_string_lossy().to_string(),
        ),
    ]
}
