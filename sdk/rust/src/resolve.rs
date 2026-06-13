use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde_yaml::Value;

use crate::merge::deep_merge_multi;
use crate::store;

/// Find the parent store by stripping the last path segment from the
/// store's hash-name.
///
/// Progressively strips trailing `-segment` portions until it finds a
/// sibling store directory with a `.meta` file.
pub fn find_parent_store(store_path: &Path) -> Option<PathBuf> {
    let store_name = store_path.file_name()?.to_string_lossy().to_string();
    let state = store_path.parent()?;

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
            }
            None => return None,
        }
    }
}

/// Walk up the parent chain, returning stores in order from
/// oldest ancestor to the given store (grandparent, parent, child).
pub fn resolve_chain(store_path: &Path) -> Vec<PathBuf> {
    let mut chain = vec![store_path.to_path_buf()];
    let mut current = store_path.to_path_buf();

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
/// at the root level, earlier layers are discarded.
pub fn resolve_config(chain: &[PathBuf], name: &str) -> Result<Value> {
    let mut layers: Vec<Value> = Vec::new();

    for s in chain {
        let active = store::active_path(s, name);
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
pub fn resolve_active(store_path: &Path, name: &str) -> Result<Value> {
    let env_name = std::env::var("DC_ENV").unwrap_or_else(|_| "dev".into());

    let layer_names: Vec<String> = {
        let mut v = vec!["base".to_string()];
        if !env_name.is_empty() {
            v.push(env_name);
        }
        v.push("local".to_string());
        v.push("secrets".to_string());
        v
    };

    let mut layers: Vec<Value> = Vec::new();

    for layer_name in &layer_names {
        let path = store::layer_path(store_path, name, layer_name);
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
    let active = store::active_path(store_path, name);
    store::ensure_config(store_path, name)?;
    let yaml =
        serde_yaml::to_string(&merged).context("failed to serialize resolved config")?;
    std::fs::write(&active, &yaml)
        .with_context(|| format!("failed to write active file: {}", active.display()))?;

    Ok(merged)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::meta::{self, StoreMeta};
    use tempfile::TempDir;

    fn make_store_dir(parent: &Path, name: &str) -> PathBuf {
        let s = parent.join(name);
        std::fs::create_dir_all(&s).unwrap();
        let m = StoreMeta {
            source: PathBuf::from(format!("/{}", name.replace('-', "/"))),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: Vec::new(),
        };
        meta::write_meta(&s, &m).unwrap();
        s
    }

    #[test]
    fn find_parent_store_found() {
        let tmp = TempDir::new().unwrap();
        let _parent = make_store_dir(tmp.path(), "Users-keith");
        let child = make_store_dir(tmp.path(), "Users-keith-projects");
        let found = find_parent_store(&child);
        assert!(found.is_some());
        assert_eq!(
            found.unwrap().file_name().unwrap().to_string_lossy(),
            "Users-keith"
        );
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
        let s = tmp.path().join("test-store");
        let config_dir = s.join("myapp");
        std::fs::create_dir_all(&config_dir).unwrap();

        std::fs::write(config_dir.join("base.yaml"), "host: localhost\nport: 5432").unwrap();
        std::fs::write(config_dir.join("local.yaml"), "port: 3306\ndebug: true").unwrap();

        // Set DC_ENV to a layer that doesn't exist so only base + local apply
        std::env::set_var("DC_ENV", "nonexistent");

        let result = resolve_active(&s, "myapp").unwrap();
        assert_eq!(result["host"], Value::String("localhost".into()));
        assert_eq!(
            result["port"],
            serde_yaml::from_str::<Value>("3306").unwrap()
        );
        assert_eq!(result["debug"], Value::Bool(true));

        assert!(s.join("myapp").join(".active").exists());
    }

    #[test]
    fn resolve_config_with_tombstone() {
        let tmp = TempDir::new().unwrap();

        let parent = tmp.path().join("x");
        std::fs::create_dir_all(parent.join("cfg")).unwrap();
        let parent_meta = StoreMeta {
            source: PathBuf::from("/x"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["cfg".to_string()],
        };
        meta::write_meta(&parent, &parent_meta).unwrap();
        std::fs::write(parent.join("cfg/.active"), "key: from_parent").unwrap();

        let child = tmp.path().join("x-y");
        std::fs::create_dir_all(child.join("cfg")).unwrap();
        let child_meta = StoreMeta {
            source: PathBuf::from("/x/y"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["cfg".to_string()],
        };
        meta::write_meta(&child, &child_meta).unwrap();
        std::fs::write(child.join("cfg/.active"), "_dc_pruned: true").unwrap();

        let chain = vec![parent, child];
        let result = resolve_config(&chain, "cfg").unwrap();
        assert_eq!(result, Value::Null);
    }

    #[test]
    fn resolve_config_merges_across_chain() {
        let tmp = TempDir::new().unwrap();

        let parent = tmp.path().join("a");
        std::fs::create_dir_all(parent.join("db")).unwrap();
        let pmeta = StoreMeta {
            source: PathBuf::from("/a"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["db".to_string()],
        };
        meta::write_meta(&parent, &pmeta).unwrap();
        std::fs::write(parent.join("db/.active"), "host: shared-db\nport: 5432").unwrap();

        let child = tmp.path().join("a-b");
        std::fs::create_dir_all(child.join("db")).unwrap();
        let cmeta = StoreMeta {
            source: PathBuf::from("/a/b"),
            created: "2026-01-01T00:00:00+00:00".to_string(),
            parent: None,
            configs: vec!["db".to_string()],
        };
        meta::write_meta(&child, &cmeta).unwrap();
        std::fs::write(child.join("db/.active"), "port: 3306\nname: mydb").unwrap();

        let chain = vec![parent, child];
        let result = resolve_config(&chain, "db").unwrap();
        assert_eq!(result["host"], Value::String("shared-db".into()));
        assert_eq!(
            result["port"],
            serde_yaml::from_str::<Value>("3306").unwrap()
        );
        assert_eq!(result["name"], Value::String("mydb".into()));
    }
}
