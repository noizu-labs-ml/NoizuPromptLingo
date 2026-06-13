use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

const META_FILE: &str = ".meta";

/// Store metadata persisted as `.meta` YAML inside each store directory.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StoreMeta {
    /// The original directory this store manages configs for.
    pub source: PathBuf,
    /// ISO 8601 timestamp when the store was created.
    pub created: String,
    /// Optional parent store path (for parent-chain resolution).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parent: Option<PathBuf>,
    /// List of config names in this store.
    #[serde(default)]
    pub configs: Vec<String>,
}

/// Read and parse the store's `.meta` YAML file.
pub fn read_meta(store: &Path) -> Result<StoreMeta> {
    let path = store.join(META_FILE);
    let contents = std::fs::read_to_string(&path)
        .with_context(|| format!("failed to read meta file: {}", path.display()))?;
    let meta: StoreMeta = serde_yaml::from_str(&contents)
        .with_context(|| format!("failed to parse meta file: {}", path.display()))?;
    Ok(meta)
}

/// Write the store's `.meta` YAML file.
pub fn write_meta(store: &Path, meta: &StoreMeta) -> Result<()> {
    let path = store.join(META_FILE);
    let yaml =
        serde_yaml::to_string(meta).context("failed to serialize store meta")?;
    std::fs::write(&path, yaml)
        .with_context(|| format!("failed to write meta file: {}", path.display()))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn make_store() -> (TempDir, StoreMeta) {
        let tmp = TempDir::new().unwrap();
        let meta = StoreMeta {
            source: PathBuf::from("/test/dir"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["aws".to_string()],
        };
        (tmp, meta)
    }

    #[test]
    fn write_and_read_meta() {
        let (tmp, meta) = make_store();
        write_meta(tmp.path(), &meta).unwrap();
        let loaded = read_meta(tmp.path()).unwrap();
        assert_eq!(loaded.source, meta.source);
        assert_eq!(loaded.created, meta.created);
        assert_eq!(loaded.configs, meta.configs);
        assert!(loaded.parent.is_none());
    }

    #[test]
    fn read_meta_missing_file_errors() {
        let tmp = TempDir::new().unwrap();
        assert!(read_meta(tmp.path()).is_err());
    }

    #[test]
    fn meta_with_parent() {
        let (tmp, mut meta) = make_store();
        meta.parent = Some(PathBuf::from("/parent/dir"));
        write_meta(tmp.path(), &meta).unwrap();
        let loaded = read_meta(tmp.path()).unwrap();
        assert_eq!(loaded.parent, Some(PathBuf::from("/parent/dir")));
    }
}
