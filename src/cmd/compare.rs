//! `dc compare <layer> <entry.path> --to <target>…` — compare a local secret
//! against remote copies WITHOUT printing any plaintext.

use anyhow::{anyhow, Result};

/// Fetch a remote target's value (plaintext). `Ok(None)` if the remote is missing.
fn fetch_remote(target: &crate::target::Target) -> Result<Option<String>> {
    match target {
        crate::target::Target::Infisical { path, key } => {
            let cfg = crate::infisical::InfisicalConfig::resolve(None)?;
            let client = crate::infisical::Client::login(cfg)?;
            client.get_secret(path, key)
        }
        crate::target::Target::KubeSecret { namespace, secret, key } => {
            Ok(crate::kube::read_secret_key(namespace, secret, key)?
                .map(|b| String::from_utf8_lossy(&b).to_string()))
        }
    }
}

/// Shared helper used by both `dc compare` (F) and `dc infisical compare` (G).
/// Compares one local plaintext against many targets, emitting only verdicts.
/// Returns true iff every target compared equal.
pub fn compare_local_to_targets(local: &str, tos: &[String]) -> Result<bool> {
    let mut all_equal = true;
    for raw in tos {
        let target = crate::target::parse(raw)?;
        match fetch_remote(&target) {
            Ok(Some(remote)) => {
                let eq = crate::secretcmp::eq_ct(local.as_bytes(), remote.as_bytes());
                if !eq {
                    all_equal = false;
                }
                println!("{}", crate::secretcmp::verdict(eq, target.label(), &target.display()));
            }
            Ok(None) => {
                all_equal = false;
                println!("{}", crate::secretcmp::missing(target.label(), &target.display()));
            }
            Err(e) => {
                all_equal = false;
                eprintln!("dc: {} {}: {e}", target.label(), target.display());
            }
        }
    }
    Ok(all_equal)
}

pub fn run(layer: &str, path: &str, tos: &[String]) -> Result<()> {
    if tos.is_empty() {
        return Err(anyhow!("provide at least one --to <target>"));
    }
    let local = crate::cmd::get::get_secret_plaintext(layer, path)?
        .ok_or_else(|| anyhow!("local secret `{layer} {path}` not found"))?;
    crate::audit::record(layer, path, 0, "compare");

    let all_equal = compare_local_to_targets(&local, tos)?;
    if !all_equal {
        std::process::exit(1);
    }
    Ok(())
}
