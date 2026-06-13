use std::path::{Path, PathBuf};
use anyhow::{Context, Result};
use serde_yaml::Value;

use crate::yaml::merge::deep_merge_multi;
use crate::store::layout;

/// Find the parent store by stripping the last path segment from the
/// store's hash-name.
///
/// For example, a store named `Users-keith-Github-k8-projects` checks
/// whether `Users-keith-Github-k8` exists as a sibling store.
pub fn find_parent_store(store: &Path) -> Option<PathBuf> {
    let store_name = store.file_name()?.to_string_lossy().to_string();
    let state = store.parent()?;

    // Progressively strip the last `-segment` from the store name
    let mut name = store_name.as_str();
    loop {
        match name.rfind('-') {
            Some(pos) => {
                name = &name[..pos];
                if name.is_empty() {
                    return None;
                }
                let candidate = state.join(name);
                if candidate.exists() && candidate.join(".meta").exists() {
                    return Some(candidate);
                }
                // Not found — keep stripping
            }
            None => return None,
        }
    }
}

/// Walk up the parent chain, returning stores in order from
/// oldest ancestor to the given store (grandparent, parent, child).
pub fn resolve_chain(store: &Path) -> Vec<PathBuf> {
    let mut chain = vec![store.to_path_buf()];
    let mut current = store.to_path_buf();

    while let Some(parent) = find_parent_store(&current) {
        chain.push(parent.clone());
        current = parent;
    }

    chain.reverse();
    chain
}

/// Resolve a named config across the parent chain by deep-merging
/// each store's `.active` file in chain order (oldest first).
///
/// If a store's `.active` for this config contains `_dc_pruned: true`
/// at the root level, the config is considered deleted from that point
/// and earlier layers are discarded.
pub fn resolve_config(chain: &[PathBuf], name: &str) -> Result<Value> {
    let mut layers: Vec<Value> = Vec::new();

    for store in chain {
        let active = layout::active_path(store, name);
        if !active.exists() {
            continue;
        }
        let contents = std::fs::read_to_string(&active)
            .with_context(|| format!("failed to read active file: {}", active.display()))?;
        let val: Value = serde_yaml::from_str(&contents)
            .with_context(|| format!("failed to parse active file: {}", active.display()))?;

        // Check for tombstone at root level
        if let Value::Mapping(ref map) = val {
            let pruned = map
                .get(Value::String("_dc_pruned".into()))
                .and_then(|v| v.as_bool())
                .unwrap_or(false);
            if pruned {
                // Config is deleted from this point — discard all prior layers
                layers.clear();
                continue;
            }
        }

        layers.push(val);
    }

    Ok(deep_merge_multi(&layers))
}

/// Resolve a single store's layers for a named config.
///
/// Merge order: `base.yaml` -> `{DC_ENV}.yaml` -> `local.yaml` -> `secrets.yaml`.
/// Missing layers are skipped. The result is written to the `.active` file.
pub fn resolve_active(store: &Path, name: &str) -> Result<Value> {
    let env_name = std::env::var("DC_ENV").unwrap_or_else(|_| "dev".into());

    let layer_names: Vec<&str> = {
        let mut v = vec!["base"];
        if !env_name.is_empty() {
            // We'll handle env layer below since we need the owned string
            v.push("__env__");
        }
        v.push("local");
        v.push("secrets");
        v
    };

    let mut layers: Vec<Value> = Vec::new();

    for layer_name in &layer_names {
        let actual_name = if *layer_name == "__env__" {
            env_name.as_str()
        } else {
            layer_name
        };

        let path = layout::layer_path(store, name, actual_name);
        if !path.exists() {
            continue;
        }
        let contents = std::fs::read_to_string(&path)
            .with_context(|| format!("failed to read layer: {}", path.display()))?;
        let val: Value = serde_yaml::from_str(&contents)
            .with_context(|| format!("failed to parse layer: {}", path.display()))?;
        layers.push(val);
    }

    let merged = deep_merge_multi(&layers);

    // Write the resolved result to .active
    let active = layout::active_path(store, name);
    // Ensure the config directory exists
    layout::ensure_config(store, name)?;
    let yaml = serde_yaml::to_string(&merged)
        .context("failed to serialize resolved config")?;
    std::fs::write(&active, &yaml)
        .with_context(|| format!("failed to write active file: {}", active.display()))?;

    Ok(merged)
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    /// Helper: create a store directory with .meta
    fn make_store_dir(parent: &Path, name: &str) -> PathBuf {
        let store = parent.join(name);
        std::fs::create_dir_all(&store).unwrap();
        let meta = crate::store::meta::StoreMeta {
            source: PathBuf::from(format!("/{}", name.replace('-', "/"))),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: Vec::new(),
        };
        crate::store::meta::write_meta(&store, &meta).unwrap();
        store
    }

    #[test]
    fn find_parent_store_found() {
        let tmp = TempDir::new().unwrap();
        let _parent = make_store_dir(tmp.path(), "Users-keith");
        let child = make_store_dir(tmp.path(), "Users-keith-projects");
        let found = find_parent_store(&child);
        assert!(found.is_some());
        assert_eq!(found.unwrap().file_name().unwrap().to_string_lossy(), "Users-keith");
    }

    #[test]
    fn find_parent_store_not_found() {
        let tmp = TempDir::new().unwrap();
        let child = make_store_dir(tmp.path(), "Users-keith-projects");
        let found = find_parent_store(&child);
        assert!(found.is_none());
    }

    #[test]
    fn find_parent_store_skips_missing_intermediate() {
        let tmp = TempDir::new().unwrap();
        // Create grandparent "a" but NOT intermediate "a-b"
        let _gp = make_store_dir(tmp.path(), "a");
        let child = make_store_dir(tmp.path(), "a-b-c");
        let found = find_parent_store(&child);
        assert!(found.is_some());
        assert_eq!(found.unwrap().file_name().unwrap().to_string_lossy(), "a");
    }

    #[test]
    fn resolve_chain_builds_ordered_list() {
        let tmp = TempDir::new().unwrap();
        let _gp = make_store_dir(tmp.path(), "a");
        let _p = make_store_dir(tmp.path(), "a-b");
        let child = make_store_dir(tmp.path(), "a-b-c");
        let chain = resolve_chain(&child);
        assert_eq!(chain.len(), 3);
        assert_eq!(chain[0].file_name().unwrap().to_string_lossy(), "a");
        assert_eq!(chain[1].file_name().unwrap().to_string_lossy(), "a-b");
        assert_eq!(chain[2].file_name().unwrap().to_string_lossy(), "a-b-c");
    }

    #[test]
    fn resolve_active_merges_layers() {
        let tmp = TempDir::new().unwrap();
        let store = tmp.path().join("test-store");
        let config_dir = store.join("myapp");
        std::fs::create_dir_all(&config_dir).unwrap();

        // base layer
        std::fs::write(config_dir.join("base.yaml"), "host: localhost\nport: 5432").unwrap();
        // local override
        std::fs::write(config_dir.join("local.yaml"), "port: 3306\ndebug: true").unwrap();

        // Set DC_ENV to a layer that doesn't exist so only base + local apply
        std::env::set_var("DC_ENV", "nonexistent");

        let result = resolve_active(&store, "myapp").unwrap();
        assert_eq!(result["host"], Value::String("localhost".into()));
        assert_eq!(result["port"], serde_yaml::from_str::<Value>("3306").unwrap());
        assert_eq!(result["debug"], Value::Bool(true));

        // .active should exist
        assert!(store.join("myapp").join(".active").exists());
    }

    #[test]
    fn resolve_config_with_tombstone() {
        let tmp = TempDir::new().unwrap();

        // Create two stores with active files
        let parent = tmp.path().join("x");
        std::fs::create_dir_all(parent.join("cfg")).unwrap();
        let parent_meta = crate::store::meta::StoreMeta {
            source: PathBuf::from("/x"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["cfg".to_string()],
        };
        crate::store::meta::write_meta(&parent, &parent_meta).unwrap();
        std::fs::write(parent.join("cfg/.active"), "key: from_parent").unwrap();

        let child = tmp.path().join("x-y");
        std::fs::create_dir_all(child.join("cfg")).unwrap();
        let child_meta = crate::store::meta::StoreMeta {
            source: PathBuf::from("/x/y"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["cfg".to_string()],
        };
        crate::store::meta::write_meta(&child, &child_meta).unwrap();
        std::fs::write(child.join("cfg/.active"), "_dc_pruned: true").unwrap();

        let chain = vec![parent.clone(), child.clone()];
        let result = resolve_config(&chain, "cfg").unwrap();
        // Tombstone clears everything, and since there's nothing after, result is Null
        assert_eq!(result, Value::Null);
    }

    #[test]
    fn resolve_config_merges_across_chain() {
        let tmp = TempDir::new().unwrap();

        let parent = tmp.path().join("a");
        std::fs::create_dir_all(parent.join("db")).unwrap();
        let pmeta = crate::store::meta::StoreMeta {
            source: PathBuf::from("/a"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["db".to_string()],
        };
        crate::store::meta::write_meta(&parent, &pmeta).unwrap();
        std::fs::write(parent.join("db/.active"), "host: shared-db\nport: 5432").unwrap();

        let child = tmp.path().join("a-b");
        std::fs::create_dir_all(child.join("db")).unwrap();
        let cmeta = crate::store::meta::StoreMeta {
            source: PathBuf::from("/a/b"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["db".to_string()],
        };
        crate::store::meta::write_meta(&child, &cmeta).unwrap();
        std::fs::write(child.join("db/.active"), "port: 3306\nname: mydb").unwrap();

        let chain = vec![parent, child];
        let result = resolve_config(&chain, "db").unwrap();
        assert_eq!(result["host"], Value::String("shared-db".into()));
        assert_eq!(result["port"], serde_yaml::from_str::<Value>("3306").unwrap());
        assert_eq!(result["name"], Value::String("mydb".into()));
    }
}
