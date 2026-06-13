//! Config layering: scan upward for parent `.agent-sandbox/config` files and
//! deep-merge layers into an effective [`SandboxConfig`].
//!
//! Merge order, lowest priority first: `template <- parent(far..near) <- project`.
//! Mappings merge recursively; scalars and sequences are replaced wholesale by
//! the higher-priority layer.

use super::{Project, SandboxConfig};
use crate::error::Result;
use crate::paths;
use anyhow::Context;
use serde_yaml::Value;
use std::path::Path;

/// Read a config file into a raw YAML [`Value`].
pub fn config_value(path: &Path) -> Result<Value> {
    let raw = std::fs::read_to_string(path)
        .with_context(|| format!("reading config {}", path.display()))?;
    let v: Value =
        serde_yaml::from_str(&raw).with_context(|| format!("parsing config {}", path.display()))?;
    Ok(v)
}

/// Parent config layers above the project, ordered lowest→highest priority
/// (farthest ancestor first, nearest parent last). The project's own config is
/// not included.
pub fn parent_config_values(project: &Project) -> Result<Vec<Value>> {
    let mut values = Vec::new(); // nearest-first
    let mut dir = project.root.parent();
    while let Some(d) = dir {
        let cfg = d.join(paths::PROJECT_DIR).join(paths::CONFIG_FILE);
        if cfg.exists() {
            values.push(config_value(&cfg)?);
        }
        dir = d.parent();
    }
    values.reverse(); // -> farthest-first (lowest priority first)
    Ok(values)
}

/// Deep-merge `over` onto `base`; `over` wins for any non-mapping node.
pub fn merge_values(base: Value, over: Value) -> Value {
    match (base, over) {
        (Value::Mapping(mut b), Value::Mapping(o)) => {
            for (k, ov) in o {
                let merged = match b.get(&k).cloned() {
                    Some(bv) => merge_values(bv, ov),
                    None => ov,
                };
                b.insert(k, merged);
            }
            Value::Mapping(b)
        }
        (_, over) => over,
    }
}

/// Fold-merge ordered layers (lowest priority first) and deserialize. An empty
/// layer list yields the default config.
pub fn materialize(layers: &[Value]) -> Result<SandboxConfig> {
    if layers.is_empty() {
        return Ok(SandboxConfig::default());
    }
    let mut acc = Value::Mapping(Default::default());
    for layer in layers {
        acc = merge_values(acc, layer.clone());
    }
    let cfg: SandboxConfig =
        serde_yaml::from_value(acc).context("merging layered config")?;
    Ok(cfg)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v(yaml: &str) -> Value {
        serde_yaml::from_str(yaml).unwrap()
    }

    #[test]
    fn mappings_merge_recursively() {
        let base = v("agent:\n  default: claude\n  dangerous: true\napps: [shell]\n");
        let over = v("agent:\n  default: codex\napps: [node, rust]\n");
        let merged = merge_values(base, over);
        let cfg: SandboxConfig = serde_yaml::from_value(merged).unwrap();
        assert_eq!(cfg.agent.default, "codex"); // overridden
        assert!(cfg.agent.dangerous); // preserved from base
        assert_eq!(cfg.apps, vec!["node", "rust"]); // sequence replaced wholesale
    }

    #[test]
    fn higher_layer_wins_in_order() {
        let layers = vec![
            v("name: tmpl\napps: [shell]\ninternet_access: false\n"),
            v("apps: [shell, node]\n"), // parent
            v("internet_access: true\n"), // project
        ];
        let cfg = materialize(&layers).unwrap();
        assert_eq!(cfg.name.as_deref(), Some("tmpl"));
        assert_eq!(cfg.apps, vec!["shell", "node"]);
        assert!(cfg.internet_access);
    }

    #[test]
    fn empty_layers_yield_default() {
        let cfg = materialize(&[]).unwrap();
        assert_eq!(cfg.agent.default, "claude");
    }
}
