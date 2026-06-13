use anyhow::Result;
use serde_yaml::Value;
use std::collections::BTreeMap;
use std::path::Path;

fn collect_leaf_keys(val: &Value, prefix: &str, keys: &mut Vec<String>) {
    match val {
        Value::Mapping(m) => {
            for (k, v) in m {
                if let Some(key_str) = k.as_str() {
                    let path = if prefix.is_empty() {
                        key_str.to_string()
                    } else {
                        format!("{}.{}", prefix, key_str)
                    };
                    collect_leaf_keys(v, &path, keys);
                }
            }
        }
        _ => {
            keys.push(prefix.to_string());
        }
    }
}

fn secrets_for_store(store: &Path) -> Result<BTreeMap<String, Vec<String>>> {
    let mut result = BTreeMap::new();
    let entries = std::fs::read_dir(store)?;

    for entry in entries {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            continue;
        }
        let name = entry.file_name();
        let name_str = name.to_string_lossy();
        if name_str.starts_with('.') || name_str == "history" {
            continue;
        }

        let secrets_path = store.join(&*name_str).join("secrets.yaml");
        if !secrets_path.exists() {
            continue;
        }
        let contents = std::fs::read_to_string(&secrets_path)?;
        let val: Value = serde_yaml::from_str(&contents)?;
        let mut keys = Vec::new();
        collect_leaf_keys(&val, "", &mut keys);
        if !keys.is_empty() {
            result.insert(name_str.into_owned(), keys);
        }
    }

    Ok(result)
}

pub fn run(json: bool) -> Result<()> {
    let store = crate::store::find_current_store()?;
    let chain = crate::store::resolve::resolve_chain(&store);

    let mut all: BTreeMap<String, Vec<String>> = BTreeMap::new();

    for s in &chain {
        let store_secrets = secrets_for_store(s)?;
        for (config, keys) in store_secrets {
            let entry = all.entry(config).or_default();
            for k in keys {
                if !entry.contains(&k) {
                    entry.push(k);
                }
            }
        }
    }

    if json {
        let j = serde_json::to_string_pretty(&all)?;
        println!("{}", j);
        return Ok(());
    }

    if all.is_empty() {
        println!("No secrets found in any config.");
        return Ok(());
    }

    let total: usize = all.values().map(|v| v.len()).sum();
    println!("{} secret(s) across {} config(s)\n", total, all.len());

    for (config, keys) in &all {
        println!("{}:", config);
        for key in keys {
            println!("  {}", key);
        }
        println!();
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn collect_leaf_keys_flat() {
        let val: Value = serde_yaml::from_str("a: 1\nb: hello\nc: true").unwrap();
        let mut keys = Vec::new();
        collect_leaf_keys(&val, "", &mut keys);
        assert_eq!(keys.len(), 3);
        assert!(keys.contains(&"a".to_string()));
        assert!(keys.contains(&"b".to_string()));
        assert!(keys.contains(&"c".to_string()));
    }

    #[test]
    fn collect_leaf_keys_nested() {
        let val: Value = serde_yaml::from_str("db:\n  host: x\n  port: 5432\ntop: v").unwrap();
        let mut keys = Vec::new();
        collect_leaf_keys(&val, "", &mut keys);
        assert_eq!(keys.len(), 3);
        assert!(keys.contains(&"db.host".to_string()));
        assert!(keys.contains(&"db.port".to_string()));
        assert!(keys.contains(&"top".to_string()));
    }

    #[test]
    fn secrets_for_store_picks_up_secrets_yaml() {
        let tmp = TempDir::new().unwrap();
        let cfg = tmp.path().join("myapp");
        std::fs::create_dir_all(&cfg).unwrap();
        std::fs::write(cfg.join("secrets.yaml"), "api_key: abc\ndb:\n  password: secret").unwrap();

        let no_secrets = tmp.path().join("other");
        std::fs::create_dir_all(&no_secrets).unwrap();
        std::fs::write(no_secrets.join("base.yaml"), "host: localhost").unwrap();

        let result = secrets_for_store(tmp.path()).unwrap();
        assert_eq!(result.len(), 1);
        assert!(result.contains_key("myapp"));
        let keys = &result["myapp"];
        assert!(keys.contains(&"api_key".to_string()));
        assert!(keys.contains(&"db.password".to_string()));
    }
}
