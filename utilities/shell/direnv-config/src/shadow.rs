//! Shadow ("locked-down") secret store.
//!
//! `dc config secure <subject> <path>` moves a secret out of the normal layer
//! files and `.envrc*` source into `<project>/.secrets/restricted.config.yaml`,
//! leaving a `⛔` sentinel behind. A `⛔` value resolves through here and is
//! only revealed with the stricter `--reveal-restricted` flag (audited).

use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};
use serde_yaml::Value;
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

const SHADOW_FILE: &str = ".secrets/restricted.config.yaml";

#[derive(Serialize, Deserialize)]
struct ShadowStore {
    version: u32,
    #[serde(default)]
    entries: BTreeMap<String, ShadowEntry>,
}

impl Default for ShadowStore {
    fn default() -> Self {
        ShadowStore { version: 1, entries: BTreeMap::new() }
    }
}

#[derive(Serialize, Deserialize)]
struct ShadowEntry {
    cipher: String,
    tier: u8,
    #[serde(skip_serializing_if = "Option::is_none")]
    note: Option<String>,
    secured_at: String,
    secured_by: String,
}

fn entry_key(subject: &str, path: &str) -> String {
    format!("{subject}/{path}")
}

fn shadow_path() -> Result<PathBuf> {
    let store = crate::store::find_current_store()?;
    let meta = crate::store::meta::read_meta(&store)?;
    Ok(meta.source.join(SHADOW_FILE))
}

fn load_store(path: &Path) -> ShadowStore {
    if path.exists() {
        std::fs::read_to_string(path)
            .ok()
            .and_then(|c| serde_yaml::from_str(&c).ok())
            .unwrap_or_default()
    } else {
        ShadowStore::default()
    }
}

/// Decrypt a shadow entry to plaintext (pure; testable without a store).
fn resolve_in(store: &ShadowStore, subject: &str, path: &str, key: &[u8; 32]) -> Result<Option<String>> {
    match store.entries.get(&entry_key(subject, path)) {
        Some(e) => {
            let (_t, plain) = crate::crypto::decode_token(&e.cipher, key)?;
            Ok(Some(plain))
        }
        None => Ok(None),
    }
}

/// Resolve a `⛔` shadowed secret to its plaintext, if present.
pub fn resolve(subject: &str, path: &str) -> Result<Option<String>> {
    let p = shadow_path()?;
    let store = load_store(&p);
    if !store.entries.contains_key(&entry_key(subject, path)) {
        return Ok(None);
    }
    let key = crate::settings::key()?;
    resolve_in(&store, subject, path, &key)
}

/// Move a secret into the shadow store and leave `⛔` sentinels behind in both
/// the state store and the `.envrc*` source.
pub fn secure(subject: &str, path: &str, note: Option<&str>) -> Result<()> {
    // Grab the current value from the resolved store.
    let token = crate::cmd::get::dc_lookup(subject, path)
        .ok_or_else(|| anyhow!("no value found for `{subject} {path}`"))?;
    if crate::secret::is_restricted_sentinel(&token) {
        return Err(anyhow!("`{subject} {path}` is already secured (⛔)"));
    }

    let key = crate::settings::key()?;
    let (cipher, tier) = if crate::crypto::is_encrypted(&token) {
        (token.clone(), crate::crypto::token_tier(&token).unwrap_or(0))
    } else {
        // Plain value — encrypt it on the way into the shadow store.
        (crate::crypto::encode_token(&token, 0, &key)?, 0)
    };

    // Write the shadow entry.
    let p = shadow_path()?;
    if let Some(parent) = p.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let mut store = load_store(&p);
    store.entries.insert(
        entry_key(subject, path),
        ShadowEntry {
            cipher,
            tier,
            note: note.map(|s| s.to_string()),
            secured_at: chrono::Utc::now().to_rfc3339(),
            secured_by: std::env::var("USER").unwrap_or_else(|_| "unknown".to_string()),
        },
    );
    std::fs::write(&p, serde_yaml::to_string(&store)?)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let _ = std::fs::set_permissions(&p, std::fs::Permissions::from_mode(0o600));
    }

    // Replace the value with ⛔ in the state store (delete from non-secret
    // layers, set the sentinel in the highest-precedence secrets layer).
    set_store_sentinel(subject, path)?;

    // Best-effort: replace the value in the .envrc* source too.
    let rewrote = crate::cmd::config::write_sentinel(subject, path).unwrap_or(false);

    crate::audit::record(subject, path, tier, "secure");
    println!(
        "secured {subject} {path} → {} (⛔ sentinel left in store{})",
        p.display(),
        if rewrote { " and .envrc" } else { "" }
    );
    Ok(())
}

fn set_store_sentinel(subject: &str, path: &str) -> Result<()> {
    let store = crate::store::find_current_store()?;
    // Remove the real value from non-secret layers.
    for layer in ["base", "local", "dev", "prod"] {
        let lf = crate::store::layout::layer_path(&store, subject, layer);
        if !lf.exists() {
            continue;
        }
        if let Ok(content) = std::fs::read_to_string(&lf) {
            if let Ok(mut v) = serde_yaml::from_str::<Value>(&content) {
                if crate::yaml::path::delete_path(&mut v, path) {
                    std::fs::write(&lf, serde_yaml::to_string(&v)?)?;
                }
            }
        }
    }
    // Set ⛔ in the secrets layer (overrides any remaining value on merge).
    let sf = crate::store::layout::layer_path(&store, subject, "secrets");
    let mut sv = if sf.exists() {
        serde_yaml::from_str(&std::fs::read_to_string(&sf)?)
            .unwrap_or_else(|_| Value::Mapping(serde_yaml::Mapping::new()))
    } else {
        Value::Mapping(serde_yaml::Mapping::new())
    };
    crate::yaml::path::set_path(&mut sv, path, Value::String("⛔".to_string()))?;
    std::fs::write(&sf, serde_yaml::to_string(&sv)?)?;
    crate::store::resolve::resolve_active(&store, subject)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const KEY: [u8; 32] = [11u8; 32];

    #[test]
    fn shadow_entry_round_trips() {
        let mut store = ShadowStore::default();
        let cipher = crate::crypto::encode_token("locked-value", 3, &KEY).unwrap();
        store.entries.insert(
            entry_key("cf", "access.client_secret"),
            ShadowEntry {
                cipher,
                tier: 3,
                note: Some("PCI".into()),
                secured_at: "2026-06-02T00:00:00Z".into(),
                secured_by: "tester".into(),
            },
        );
        // serialize → deserialize → resolve
        let yaml = serde_yaml::to_string(&store).unwrap();
        let loaded: ShadowStore = serde_yaml::from_str(&yaml).unwrap();
        let got = resolve_in(&loaded, "cf", "access.client_secret", &KEY).unwrap();
        assert_eq!(got.as_deref(), Some("locked-value"));
    }

    #[test]
    fn missing_entry_resolves_none() {
        let store = ShadowStore::default();
        assert!(resolve_in(&store, "cf", "nope", &KEY).unwrap().is_none());
    }
}
