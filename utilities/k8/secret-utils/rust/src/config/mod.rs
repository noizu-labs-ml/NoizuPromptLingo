pub mod v1;
pub mod legacy;

use anyhow::Result;
use std::path::{Path, PathBuf};

use crate::error::InfisicalError;

pub use v1::SecretsConfigV1;
pub use legacy::SecretsConfigLegacy;

pub enum SecretsConfig {
    V1(SecretsConfigV1),
    Legacy(SecretsConfigLegacy),
}

impl SecretsConfig {
    pub fn load(path: &Path) -> Result<Self> {
        let raw = std::fs::read_to_string(path)
            .map_err(|e| anyhow::anyhow!("read {:?}: {e}", path))?;

        // Detect format by apiVersion field
        if raw.contains("apiVersion: secrets-tools/v1") {
            let cfg: SecretsConfigV1 = serde_yaml::from_str(&raw)
                .map_err(|e| InfisicalError::ConfigParse(e.to_string()))?;
            Ok(SecretsConfig::V1(cfg))
        } else {
            let cfg: SecretsConfigLegacy = serde_yaml::from_str(&raw)
                .map_err(|e| InfisicalError::ConfigParse(e.to_string()))?;
            Ok(SecretsConfig::Legacy(cfg))
        }
    }
}

/// Walk up from cwd to find the secrets config file.
pub fn discover_config(explicit: Option<&str>) -> Result<PathBuf> {
    if let Some(p) = explicit {
        let path = PathBuf::from(p);
        if path.exists() {
            return Ok(path);
        }
        anyhow::bail!("config file not found: {p}");
    }

    if let Ok(env_path) = std::env::var("INFISICAL_SECRETS_FILE") {
        let path = PathBuf::from(&env_path);
        if path.exists() {
            return Ok(path);
        }
    }

    let candidates = [
        ".infisical-secrets.yaml",
        "infisical-secrets.yaml",
        "secrets.yaml",
    ];

    let mut dir = std::env::current_dir()?;
    loop {
        for name in &candidates {
            let candidate = dir.join(name);
            if candidate.exists() {
                return Ok(candidate);
            }
        }
        if !dir.pop() {
            break;
        }
    }

    Err(InfisicalError::ConfigNotFound.into())
}
