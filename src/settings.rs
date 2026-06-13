//! Global `dc` settings — `~/.config/direnv-config/settings.yaml`.
//!
//! Holds the symmetric AEAD key used to encrypt secret values at rest and an
//! optional override for the audit-log path. This file is distinct from the
//! per-directory state store under `~/.local/state/direnv-config/`.

use anyhow::{anyhow, Context, Result};
use serde::Deserialize;
use std::path::PathBuf;

#[derive(Debug, Deserialize)]
struct SettingsFile {
    /// base64 (standard) encoded 32-byte XChaCha20-Poly1305 key.
    key: Option<String>,
    /// Optional override for the audit log path.
    audit_log: Option<String>,
}

pub struct Settings {
    pub key: [u8; 32],
    pub audit_log: Option<PathBuf>,
}

/// Resolve the settings file path: `$DC_SETTINGS` → `~/.config/direnv-config/settings.yaml`.
pub fn settings_path() -> PathBuf {
    if let Ok(p) = std::env::var("DC_SETTINGS") {
        return PathBuf::from(p);
    }
    dirs::config_dir()
        .map(|c| c.join("direnv-config").join("settings.yaml"))
        .unwrap_or_else(|| PathBuf::from(".config/direnv-config/settings.yaml"))
}

/// Load and validate the settings file.
pub fn load() -> Result<Settings> {
    let path = settings_path();
    let raw = std::fs::read_to_string(&path).with_context(|| {
        format!(
            "reading settings file {} — create it with `key: <base64 32-byte key>` (e.g. `openssl rand -base64 32`)",
            path.display()
        )
    })?;
    let parsed: SettingsFile = serde_yaml::from_str(&raw)
        .with_context(|| format!("parsing settings file {}", path.display()))?;

    let key_b64 = parsed.key.ok_or_else(|| {
        anyhow!(
            "no encryption key in {} — add `key: <base64 32-byte key>` (generate with `openssl rand -base64 32`)",
            path.display()
        )
    })?;
    let key_bytes = crate::crypto::b64_standard_decode(key_b64.trim())
        .with_context(|| "decoding `key` from settings.yaml")?;
    if key_bytes.len() != 32 {
        return Err(anyhow!(
            "encryption key must be 32 bytes after base64-decode (got {})",
            key_bytes.len()
        ));
    }
    let mut key = [0u8; 32];
    key.copy_from_slice(&key_bytes);

    Ok(Settings {
        key,
        audit_log: parsed.audit_log.map(PathBuf::from),
    })
}

/// Convenience: load just the AEAD key.
pub fn key() -> Result<[u8; 32]> {
    Ok(load()?.key)
}
