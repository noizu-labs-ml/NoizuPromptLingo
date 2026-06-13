//! `dc push <subject> <section.path> --to infisical://… | kubernetes://…`
//!
//! Force-push local (decrypted) secret(s) to a remote. A `section.path` that
//! resolves to a subtree pushes each leaf. Dry-run by default; the push payload
//! (request body / kubectl stdin) is the only intended plaintext egress.

use anyhow::{anyhow, bail, Result};
use serde_yaml::Value;
use std::io::Write;

enum PushTarget {
    Infisical { path: String },
    Kube { namespace: String, secret: String },
}

fn parse_push_target(raw: &str) -> Result<PushTarget> {
    if let Some(r) = raw.strip_prefix("infisical://") {
        return Ok(PushTarget::Infisical { path: format!("/{}", r.trim_matches('/')) });
    }
    let kube = raw.strip_prefix("kubernetes://").or_else(|| raw.strip_prefix("k8://"));
    if let Some(r) = kube {
        let parts: Vec<&str> = r.split('/').filter(|s| !s.is_empty()).collect();
        if parts.len() != 2 {
            bail!("kubernetes push target needs <namespace>/<secret>: {raw}");
        }
        return Ok(PushTarget::Kube { namespace: parts[0].into(), secret: parts[1].into() });
    }
    bail!("unrecognized push target (expected infisical:// or kubernetes://): {raw}")
}

fn collect_leaves(val: &Value, prefix: &str, out: &mut Vec<String>) {
    match val {
        Value::Mapping(m) => {
            for (k, v) in m {
                let Some(ks) = k.as_str() else { continue };
                if ks.starts_with('_') {
                    continue;
                }
                let p = if prefix.is_empty() {
                    ks.to_string()
                } else {
                    format!("{prefix}.{ks}")
                };
                collect_leaves(v, &p, out);
            }
        }
        _ => out.push(prefix.to_string()),
    }
}

/// Derive a remote KEY from a leaf's final segment (uppercased, sanitized).
fn remote_key(abs_path: &str) -> String {
    let last = abs_path.rsplit('.').next().unwrap_or(abs_path);
    last.chars()
        .map(|c| if c.is_alphanumeric() { c.to_ascii_uppercase() } else { '_' })
        .collect()
}

fn confirm(prompt: &str) -> Result<bool> {
    eprint!("{prompt} [y/N] ");
    std::io::stderr().flush().ok();
    let mut buf = String::new();
    std::io::stdin().read_line(&mut buf)?;
    Ok(matches!(buf.trim().to_lowercase().as_str(), "y" | "yes"))
}

pub fn run(subject: &str, section_path: &str, tos: &[String], dry_run: bool, yes: bool) -> Result<()> {
    if tos.is_empty() {
        return Err(anyhow!("provide at least one --to <target>"));
    }
    let store = crate::store::find_current_store()?;
    let chain = crate::store::resolve::resolve_chain(&store);
    let config = crate::store::resolve::resolve_config(&chain, subject)?;
    let subtree = if section_path.is_empty() {
        config
    } else {
        crate::yaml::path::get_path(&config, section_path)
            .ok_or_else(|| anyhow!("path `{section_path}` not found in `{subject}`"))?
    };

    // Enumerate leaves (relative to the subtree) → absolute paths within subject.
    let mut rel_leaves = Vec::new();
    collect_leaves(&subtree, "", &mut rel_leaves);
    let mut leaves: Vec<(String, String)> = Vec::new(); // (abs_path, plaintext)
    for rel in &rel_leaves {
        let abs = if rel.is_empty() {
            section_path.to_string()
        } else if section_path.is_empty() {
            rel.clone()
        } else {
            format!("{section_path}.{rel}")
        };
        if let Some(pt) = crate::cmd::get::get_secret_plaintext(subject, &abs)? {
            leaves.push((abs, pt));
        }
    }
    if leaves.is_empty() {
        bail!("no values found under `{subject} {section_path}`");
    }

    for raw in tos {
        let target = parse_push_target(raw)?;
        match target {
            PushTarget::Infisical { path } => {
                let cfg = crate::infisical::InfisicalConfig::resolve(None)?;
                let client = crate::infisical::Client::login(cfg)?;
                // Plan.
                let mut changes = false;
                let mut plan = Vec::new();
                for (abs, pt) in &leaves {
                    let key = remote_key(abs);
                    let action = match client.get_secret(&path, &key)? {
                        Some(existing) if existing == *pt => "= unchanged",
                        Some(_) => {
                            changes = true;
                            "~ update"
                        }
                        None => {
                            changes = true;
                            "+ create"
                        }
                    };
                    println!("{action}  infisical {path}/{key}");
                    plan.push((abs.clone(), key, pt.clone()));
                }
                if dry_run || !changes {
                    continue;
                }
                if !yes && !confirm(&format!("Push {} secret(s) to infisical {path}?", plan.len()))? {
                    eprintln!("aborted");
                    continue;
                }
                for (abs, key, pt) in &plan {
                    crate::audit::record(subject, abs, 0, "push");
                    let outcome = client.upsert_secret(&path, key, pt)?;
                    println!("  {:?}  infisical {path}/{key}", outcome);
                }
            }
            PushTarget::Kube { namespace, secret } => {
                let mut changes = false;
                let mut plan = Vec::new();
                for (abs, pt) in &leaves {
                    let key = remote_key(abs);
                    let outcome =
                        crate::kube::upsert_secret_key(&namespace, &secret, &key, pt.as_bytes(), true)?;
                    if outcome != crate::kube::KubeOutcome::Unchanged {
                        changes = true;
                    }
                    println!("{:?}  k8 {namespace}/{secret}/{key}", outcome);
                    plan.push((abs.clone(), key, pt.clone()));
                }
                if dry_run || !changes {
                    continue;
                }
                if !yes
                    && !confirm(&format!("Push {} secret(s) to k8 {namespace}/{secret}?", plan.len()))?
                {
                    eprintln!("aborted");
                    continue;
                }
                for (abs, key, pt) in &plan {
                    crate::audit::record(subject, abs, 0, "push");
                    let outcome =
                        crate::kube::upsert_secret_key(&namespace, &secret, key, pt.as_bytes(), false)?;
                    println!("  {:?}  k8 {namespace}/{secret}/{key}", outcome);
                }
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn remote_key_from_leaf() {
        assert_eq!(remote_key("db.replica.password"), "PASSWORD");
        assert_eq!(remote_key("api-token"), "API_TOKEN");
        assert_eq!(remote_key("client_id"), "CLIENT_ID");
    }

    #[test]
    fn parse_targets() {
        assert!(matches!(parse_push_target("infisical://data/postgres").unwrap(), PushTarget::Infisical { .. }));
        assert!(matches!(parse_push_target("kubernetes://ns/sec").unwrap(), PushTarget::Kube { .. }));
        assert!(parse_push_target("kubernetes://ns").is_err());
        assert!(parse_push_target("http://x").is_err());
    }

    #[test]
    fn collect_leaves_walks_tree() {
        let v: Value = serde_yaml::from_str("a: 1\nb:\n  c: 2\n  d: 3").unwrap();
        let mut out = Vec::new();
        collect_leaves(&v, "", &mut out);
        out.sort();
        assert_eq!(out, vec!["a", "b.c", "b.d"]);
    }
}
