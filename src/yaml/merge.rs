use serde_yaml::Value;

/// Check whether a map value carries the tombstone marker `_dc_pruned: true`.
fn is_tombstoned(map: &serde_yaml::Mapping) -> bool {
    map.get(Value::String("_dc_pruned".into()))
        .and_then(|v| v.as_bool())
        .unwrap_or(false)
}

/// Strip tombstoned subtrees from a Value tree (recursive).
/// Returns `None` if the value itself is a tombstoned map.
fn strip_tombstones(val: &Value) -> Option<Value> {
    match val {
        Value::Mapping(map) => {
            if is_tombstoned(map) {
                return None;
            }
            let mut out = serde_yaml::Mapping::new();
            for (k, v) in map {
                if let Some(cleaned) = strip_tombstones(v) {
                    out.insert(k.clone(), cleaned);
                }
                // else: child was tombstoned, omit it
            }
            Some(Value::Mapping(out))
        }
        Value::Sequence(seq) => {
            let cleaned: Vec<Value> = seq.iter().filter_map(|v| strip_tombstones(v)).collect();
            Some(Value::Sequence(cleaned))
        }
        other => Some(other.clone()),
    }
}

/// Deep-merge two YAML value trees.
///
/// - Maps merge key-by-key; overlay wins on conflict (recursing when both sides are maps).
/// - Sequences from overlay replace base entirely.
/// - Scalars from overlay replace base.
/// - If a merged map carries `_dc_pruned: true`, the entire subtree is treated as deleted.
///
/// Tombstoned subtrees are stripped from the final result.
pub fn deep_merge(base: &Value, overlay: &Value) -> Value {
    let merged = merge_inner(base, overlay);
    strip_tombstones(&merged).unwrap_or(Value::Null)
}

fn merge_inner(base: &Value, overlay: &Value) -> Value {
    match (base, overlay) {
        (Value::Mapping(base_map), Value::Mapping(overlay_map)) => {
            let mut out = base_map.clone();
            for (k, ov) in overlay_map {
                if let Some(bv) = base_map.get(k) {
                    out.insert(k.clone(), merge_inner(bv, ov));
                } else {
                    out.insert(k.clone(), ov.clone());
                }
            }
            Value::Mapping(out)
        }
        // Types differ or non-map types: overlay wins.
        (_, overlay) => overlay.clone(),
    }
}

/// Merge a slice of layers left-to-right. An empty slice yields `Value::Null`.
pub fn deep_merge_multi(layers: &[Value]) -> Value {
    match layers.len() {
        0 => Value::Null,
        1 => {
            strip_tombstones(&layers[0]).unwrap_or(Value::Null)
        }
        _ => {
            let mut acc = layers[0].clone();
            for layer in &layers[1..] {
                acc = merge_inner(&acc, layer);
            }
            strip_tombstones(&acc).unwrap_or(Value::Null)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_yaml::Value;

    fn yaml(s: &str) -> Value {
        serde_yaml::from_str(s).unwrap()
    }

    #[test]
    fn merge_simple_scalars() {
        let base = yaml("name: alice");
        let overlay = yaml("name: bob");
        let result = deep_merge(&base, &overlay);
        assert_eq!(result["name"], Value::String("bob".into()));
    }

    #[test]
    fn merge_adds_new_keys() {
        let base = yaml("a: 1");
        let overlay = yaml("b: 2");
        let result = deep_merge(&base, &overlay);
        assert_eq!(result["a"], yaml("1"));
        assert_eq!(result["b"], yaml("2"));
    }

    #[test]
    fn merge_nested_maps() {
        let base = yaml(
            r#"
            db:
              host: localhost
              port: 5432
            "#,
        );
        let overlay = yaml(
            r#"
            db:
              port: 3306
              name: mydb
            "#,
        );
        let result = deep_merge(&base, &overlay);
        assert_eq!(result["db"]["host"], Value::String("localhost".into()));
        assert_eq!(result["db"]["port"], yaml("3306"));
        assert_eq!(result["db"]["name"], Value::String("mydb".into()));
    }

    #[test]
    fn merge_sequence_overlay_wins() {
        let base = yaml("tags:\n  - a\n  - b");
        let overlay = yaml("tags:\n  - x");
        let result = deep_merge(&base, &overlay);
        let seq = result["tags"].as_sequence().unwrap();
        assert_eq!(seq.len(), 1);
        assert_eq!(seq[0], Value::String("x".into()));
    }

    #[test]
    fn merge_type_mismatch_overlay_wins() {
        let base = yaml("val:\n  nested: true");
        let overlay = yaml("val: 42");
        let result = deep_merge(&base, &overlay);
        assert_eq!(result["val"], yaml("42"));
    }

    #[test]
    fn merge_tombstone_removes_subtree() {
        let base = yaml(
            r#"
            keep: yes
            remove_me:
              data: important
            "#,
        );
        let overlay = yaml(
            r#"
            remove_me:
              _dc_pruned: true
            "#,
        );
        let result = deep_merge(&base, &overlay);
        assert!(result["remove_me"].is_null());
        assert!(result["keep"].as_bool() == Some(true) || result["keep"].as_str() == Some("yes"));
    }

    #[test]
    fn merge_nested_tombstone() {
        let base = yaml(
            r#"
            top:
              child:
                value: 1
            "#,
        );
        let overlay = yaml(
            r#"
            top:
              child:
                _dc_pruned: true
            "#,
        );
        let result = deep_merge(&base, &overlay);
        assert!(result["top"]["child"].is_null());
    }

    #[test]
    fn deep_merge_multi_layers() {
        let layers = vec![
            yaml("a: 1\nb: 1"),
            yaml("b: 2\nc: 2"),
            yaml("c: 3\nd: 3"),
        ];
        let result = deep_merge_multi(&layers);
        assert_eq!(result["a"], yaml("1"));
        assert_eq!(result["b"], yaml("2"));
        assert_eq!(result["c"], yaml("3"));
        assert_eq!(result["d"], yaml("3"));
    }

    #[test]
    fn deep_merge_multi_empty() {
        let result = deep_merge_multi(&[]);
        assert_eq!(result, Value::Null);
    }

    #[test]
    fn deep_merge_multi_single() {
        let result = deep_merge_multi(&[yaml("x: 1")]);
        assert_eq!(result["x"], yaml("1"));
    }
}
