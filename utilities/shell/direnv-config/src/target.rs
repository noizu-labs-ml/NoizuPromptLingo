//! Target URI grammar for `dc compare`/`dc push`.
//!
//! ```text
//! infisical://<path>/<NAME>           e.g. infisical://data/postgres/POSTGRES_PASSWORD
//! k8://<ns>/<secret>/<KEY>            e.g. k8://apps-ns/ghost-secrets/MAIL_PASSWORD
//! kubernetes://<ns>/<secret>/<KEY>    alias of k8://
//! ```
//! Infisical paths may contain multiple `/`; the LAST segment is the key and the
//! remainder is the secret path (normalized to a leading `/`).

use anyhow::{anyhow, bail, Result};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Target {
    Infisical { path: String, key: String },
    KubeSecret { namespace: String, secret: String, key: String },
}

impl Target {
    pub fn label(&self) -> &'static str {
        match self {
            Target::Infisical { .. } => "infisical",
            Target::KubeSecret { .. } => "k8",
        }
    }

    /// A non-secret, human-readable identifier (never the value).
    pub fn display(&self) -> String {
        match self {
            Target::Infisical { path, key } => format!("{path}/{key}"),
            Target::KubeSecret { namespace, secret, key } => format!("{namespace}/{secret}/{key}"),
        }
    }
}

pub fn parse(raw: &str) -> Result<Target> {
    if let Some(rest) = raw.strip_prefix("infisical://") {
        let rest = rest.trim_start_matches('/');
        let (path, key) = rest
            .rsplit_once('/')
            .ok_or_else(|| anyhow!("infisical target needs <path>/<NAME>: {raw}"))?;
        if path.is_empty() || key.is_empty() {
            bail!("infisical target needs both a path and a key: {raw}");
        }
        return Ok(Target::Infisical {
            path: format!("/{}", path.trim_matches('/')),
            key: key.to_string(),
        });
    }

    let kube_rest = raw
        .strip_prefix("kubernetes://")
        .or_else(|| raw.strip_prefix("k8://"));
    if let Some(rest) = kube_rest {
        if rest.starts_with('{') {
            bail!("pod-exec targets (k8:{{pod}}/…) are not yet supported: {raw}");
        }
        let parts: Vec<&str> = rest.split('/').filter(|s| !s.is_empty()).collect();
        if parts.len() != 3 {
            bail!("kubernetes target needs <namespace>/<secret>/<KEY>: {raw}");
        }
        return Ok(Target::KubeSecret {
            namespace: parts[0].to_string(),
            secret: parts[1].to_string(),
            key: parts[2].to_string(),
        });
    }

    bail!("unrecognized target scheme (expected infisical:// or k8://): {raw}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_infisical_multi_segment_path() {
        let t = parse("infisical://data/postgres/POSTGRES_PASSWORD").unwrap();
        assert_eq!(
            t,
            Target::Infisical { path: "/data/postgres".into(), key: "POSTGRES_PASSWORD".into() }
        );
        assert_eq!(t.display(), "/data/postgres/POSTGRES_PASSWORD");
        assert_eq!(t.label(), "infisical");
    }

    #[test]
    fn parses_infisical_leading_slash_forms() {
        assert_eq!(
            parse("infisical:///apps/ghost/MAIL").unwrap(),
            Target::Infisical { path: "/apps/ghost".into(), key: "MAIL".into() }
        );
    }

    #[test]
    fn parses_kube_and_alias() {
        let a = parse("k8://apps-ns/ghost-secrets/MAIL").unwrap();
        let b = parse("kubernetes://apps-ns/ghost-secrets/MAIL").unwrap();
        assert_eq!(a, b);
        assert_eq!(
            a,
            Target::KubeSecret {
                namespace: "apps-ns".into(),
                secret: "ghost-secrets".into(),
                key: "MAIL".into()
            }
        );
    }

    #[test]
    fn rejects_bad_targets() {
        assert!(parse("infisical://justkey").is_err());
        assert!(parse("k8://ns/secret").is_err());
        assert!(parse("k8://{pod}/x/y").is_err());
        assert!(parse("https://example.com").is_err());
    }
}
