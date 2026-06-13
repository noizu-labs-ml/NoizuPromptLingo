use std::collections::HashMap;
use serde_yaml::Value;

/// A parsed flatten rule from the `_dc.flatten` map.
///
/// Rules use the format `<config_name>.<key_path>: <ENV_VAR>` where
/// `config_name` is the named config (e.g. "cluster", "cloudflare", "tab")
/// and `key_path` is the dot-path within that config. A trailing `*` in
/// `key_path` means "iterate all keys at this level"; the corresponding `*`
/// in `env_var` is replaced with the uppercased key name.
#[derive(Debug, Clone, PartialEq)]
pub struct FlattenRule {
    /// The named config to look up (e.g. "cluster", "cloudflare", "tab").
    pub config_name: String,
    /// Dot-separated key path within the config. May end in `*` for wildcard.
    pub key_path: String,
    /// Env var name template. May contain `*` which gets replaced with the
    /// uppercased matched key when the rule is a wildcard.
    pub env_var: String,
}

impl FlattenRule {
    /// Whether this rule has a wildcard (`*`) as the final path segment.
    pub fn is_wildcard(&self) -> bool {
        self.key_path.ends_with('*') && self.env_var.contains('*')
    }

    /// The concrete (non-wildcard) prefix of the key path, without the
    /// trailing `.*` or `*`.
    pub fn prefix_path(&self) -> &str {
        if self.is_wildcard() {
            self.key_path.trim_end_matches('*').trim_end_matches('.')
        } else {
            &self.key_path
        }
    }
}

/// Result of flattening: ordered list of (env_var_name, value) pairs.
pub type FlattenResult = Vec<(String, String)>;

/// Parse flatten rules from the `_dc` config's `flatten` mapping.
///
/// Expects `dc_config` to be the Value for the `_dc` named config, containing
/// a `flatten` key whose value is a string-to-string mapping.
pub fn parse_rules(dc_config: &Value) -> Vec<FlattenRule> {
    let mut rules = Vec::new();
    let flatten_map = match dc_config.get("flatten") {
        Some(Value::Mapping(m)) => m,
        _ => return rules,
    };

    for (key, val) in flatten_map {
        let key_str = match key.as_str() {
            Some(s) => s,
            None => continue,
        };
        let env_var = match val.as_str() {
            Some(s) => s.to_string(),
            None => continue,
        };

        // Split "config_name.key.path" into config_name and key_path
        if let Some(dot_pos) = key_str.find('.') {
            rules.push(FlattenRule {
                config_name: key_str[..dot_pos].to_string(),
                key_path: key_str[dot_pos + 1..].to_string(),
                env_var,
            });
        }
    }
    rules
}

/// Convert a scalar YAML value to its string representation.
/// Returns `None` for non-scalar values (maps, sequences, tagged).
/// Null yields an empty string.
fn value_to_string(val: &Value) -> Option<String> {
    match val {
        Value::String(s) => Some(s.clone()),
        Value::Number(n) => Some(n.to_string()),
        Value::Bool(b) => Some(if *b { "true" } else { "false" }.to_string()),
        Value::Null => Some(String::new()),
        _ => None, // skip maps and sequences
    }
}

/// Traverse a YAML value tree along a dot-separated path.
fn get_nested<'a>(val: &'a Value, path: &str) -> Option<&'a Value> {
    let mut current = val;
    for segment in path.split('.') {
        match current {
            Value::Mapping(m) => {
                current = m.get(Value::String(segment.to_string()))?;
            }
            _ => return None,
        }
    }
    Some(current)
}

/// Given flatten rules and all resolved named configs, produce env var assignments.
///
/// For explicit rules, the key path is traversed directly and the leaf value
/// is converted to a string.
///
/// For wildcard rules, the map at the prefix path is iterated and each scalar
/// child is emitted with the `*` in the env var template replaced by the
/// uppercased key name. Keys starting with `_` are skipped (internal markers).
///
/// Non-scalar values and missing configs are silently skipped.
pub fn flatten(rules: &[FlattenRule], configs: &HashMap<String, Value>) -> FlattenResult {
    let mut results = Vec::new();

    for rule in rules {
        let config = match configs.get(&rule.config_name) {
            Some(c) => c,
            None => continue,
        };

        if rule.is_wildcard() {
            // Wildcard rule: iterate map keys at the wildcard level
            let prefix_path = rule.prefix_path();
            let target = if prefix_path.is_empty() {
                config
            } else {
                match get_nested(config, prefix_path) {
                    Some(v) => v,
                    None => continue,
                }
            };

            if let Value::Mapping(m) = target {
                for (k, v) in m {
                    if let Some(key_name) = k.as_str() {
                        if key_name.starts_with('_') {
                            continue; // skip _dc_* internal keys
                        }
                        if let Some(val_str) = value_to_string(v) {
                            let env_name = rule.env_var.replace('*', &key_name.to_uppercase());
                            results.push((env_name, val_str));
                        }
                    }
                }
            }
        } else {
            // Explicit rule: resolve the exact path
            if let Some(val) = get_nested(config, &rule.key_path) {
                if let Some(val_str) = value_to_string(val) {
                    results.push((rule.env_var.clone(), val_str));
                }
            }
        }
    }

    results
}

/// Returns true if the string needs shell quoting for safe `eval`.
fn needs_quoting(s: &str) -> bool {
    s.is_empty()
        || s.contains(|c: char| {
            matches!(
                c,
                ' ' | '\t'
                    | '\n'
                    | '$'
                    | '`'
                    | '\\'
                    | '"'
                    | '\''
                    | '('
                    | ')'
                    | '|'
                    | '&'
                    | ';'
                    | '<'
                    | '>'
                    | '*'
                    | '?'
                    | '['
                    | ']'
                    | '{'
                    | '}'
                    | '#'
                    | '!'
                    | '~'
            )
        })
}

/// Shell-escape a value for safe use in `eval "$(dc flatten)"`.
///
/// If the value contains any shell-special characters, it is wrapped in single
/// quotes with internal single quotes escaped as `'\''`. Otherwise the value
/// is returned as-is.
fn shell_escape(s: &str) -> String {
    if needs_quoting(s) {
        format!("'{}'", s.replace('\'', "'\\''"))
    } else {
        s.to_string()
    }
}

/// Format flatten results as `export KEY=VALUE\n` lines suitable for `eval`.
pub fn emit_exports(results: &FlattenResult) -> String {
    let mut out = String::new();
    for (key, val) in results {
        out.push_str(&format!("export {}={}\n", key, shell_escape(val)));
    }
    out
}

/// Emit exports with additional `DC_ROOT`, `DC_VERSION`, and `DC_ENV` variables
/// prepended. Used by the CLI `flatten` subcommand to provide context about
/// the active store.
pub fn emit_exports_with_dc_vars(
    results: &FlattenResult,
    store: &std::path::Path,
    version: u64,
) -> String {
    let mut out = String::new();
    out.push_str(&format!(
        "export DC_ROOT={}\n",
        shell_escape(&store.to_string_lossy())
    ));
    out.push_str(&format!("export DC_VERSION={}\n", version));
    if let Ok(env) = std::env::var("DC_ENV") {
        out.push_str(&format!("export DC_ENV={}\n", shell_escape(&env)));
    } else {
        out.push_str("export DC_ENV=dev\n");
    }
    out.push_str(&emit_exports(results));
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_yaml::Value;

    fn yaml(s: &str) -> Value {
        serde_yaml::from_str(s).unwrap()
    }

    // ── parse_rules ─────────────────────────────────────────────────────

    #[test]
    fn parse_rules_basic() {
        let dc = yaml(
            r#"
            flatten:
              cluster.kubeconfig: KUBECONFIG
              cloudflare.account_id: CF_ACCOUNT_ID
        "#,
        );
        let rules = parse_rules(&dc);
        assert_eq!(rules.len(), 2);

        let r = rules
            .iter()
            .find(|r| r.env_var == "KUBECONFIG")
            .unwrap();
        assert_eq!(r.config_name, "cluster");
        assert_eq!(r.key_path, "kubeconfig");
        assert!(!r.is_wildcard());
    }

    #[test]
    fn parse_rules_wildcard() {
        let dc = yaml(
            r#"
            flatten:
              tab.*: TAB_*
        "#,
        );
        let rules = parse_rules(&dc);
        assert_eq!(rules.len(), 1);
        assert!(rules[0].is_wildcard());
        assert_eq!(rules[0].config_name, "tab");
        assert_eq!(rules[0].env_var, "TAB_*");
    }

    #[test]
    fn parse_rules_nested_wildcard() {
        let dc = yaml(
            r#"
            flatten:
              myapp.db.*: MYAPP_DB_*
        "#,
        );
        let rules = parse_rules(&dc);
        assert_eq!(rules.len(), 1);
        assert_eq!(rules[0].prefix_path(), "db");
    }

    #[test]
    fn parse_rules_missing_flatten() {
        let dc = yaml("something_else: true");
        assert!(parse_rules(&dc).is_empty());
    }

    // ── flatten: explicit rules ─────────────────────────────────────────

    #[test]
    fn flatten_explicit_rule() {
        let rules = vec![FlattenRule {
            config_name: "cluster".into(),
            key_path: "name".into(),
            env_var: "CLUSTER_NAME".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "cluster".into(),
            yaml("name: noizu\nregion: us-east-1"),
        );
        let result = flatten(&rules, &configs);
        assert_eq!(result, vec![("CLUSTER_NAME".into(), "noizu".into())]);
    }

    #[test]
    fn flatten_nested_path() {
        let rules = vec![FlattenRule {
            config_name: "cluster".into(),
            key_path: "node_pool.min".into(),
            env_var: "NODE_POOL_MIN".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "cluster".into(),
            yaml("node_pool:\n  min: 2\n  max: 8"),
        );
        let result = flatten(&rules, &configs);
        assert_eq!(result, vec![("NODE_POOL_MIN".into(), "2".into())]);
    }

    // ── flatten: wildcard rules ─────────────────────────────────────────

    #[test]
    fn flatten_wildcard_expansion() {
        let rules = vec![FlattenRule {
            config_name: "tab".into(),
            key_path: "*".into(),
            env_var: "TAB_*".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "tab".into(),
            yaml("theme: kanagawa\nstatus: idle"),
        );
        let result = flatten(&rules, &configs);
        assert!(result.contains(&("TAB_THEME".into(), "kanagawa".into())));
        assert!(result.contains(&("TAB_STATUS".into(), "idle".into())));
        assert_eq!(result.len(), 2);
    }

    #[test]
    fn flatten_nested_wildcard() {
        let rules = vec![FlattenRule {
            config_name: "myapp".into(),
            key_path: "db.*".into(),
            env_var: "MYAPP_DB_*".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "myapp".into(),
            yaml("db:\n  host: localhost\n  port: 5432"),
        );
        let result = flatten(&rules, &configs);
        assert!(result.contains(&("MYAPP_DB_HOST".into(), "localhost".into())));
        assert!(result.contains(&("MYAPP_DB_PORT".into(), "5432".into())));
    }

    #[test]
    fn flatten_wildcard_skips_internal_keys() {
        let rules = vec![FlattenRule {
            config_name: "cfg".into(),
            key_path: "*".into(),
            env_var: "CFG_*".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "cfg".into(),
            yaml("visible: yes\n_dc_pruned: true"),
        );
        let result = flatten(&rules, &configs);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0].0, "CFG_VISIBLE");
    }

    // ── flatten: edge cases ─────────────────────────────────────────────

    #[test]
    fn flatten_missing_config_skipped() {
        let rules = vec![FlattenRule {
            config_name: "nonexistent".into(),
            key_path: "key".into(),
            env_var: "VAR".into(),
        }];
        let configs = HashMap::new();
        let result = flatten(&rules, &configs);
        assert!(result.is_empty());
    }

    #[test]
    fn flatten_nonscalar_values_skipped() {
        let rules = vec![FlattenRule {
            config_name: "data".into(),
            key_path: "*".into(),
            env_var: "DATA_*".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "data".into(),
            yaml("simple: value\nnested:\n  a: 1\n  b: 2\nlist:\n  - x\n  - y"),
        );
        let result = flatten(&rules, &configs);
        // Only the scalar "simple" should be emitted.
        assert_eq!(result, vec![("DATA_SIMPLE".into(), "value".into())]);
    }

    #[test]
    fn flatten_non_scalar_explicit_skipped() {
        let rules = vec![FlattenRule {
            config_name: "svc".into(),
            key_path: "postgres".into(),
            env_var: "PG".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "svc".into(),
            yaml("postgres:\n  host: localhost\n  port: 5432"),
        );
        let result = flatten(&rules, &configs);
        assert!(result.is_empty()); // postgres is a map, should be skipped
    }

    #[test]
    fn flatten_bool_and_number_conversion() {
        let rules = vec![FlattenRule {
            config_name: "cfg".into(),
            key_path: "*".into(),
            env_var: "CFG_*".into(),
        }];
        let mut configs = HashMap::new();
        configs.insert(
            "cfg".into(),
            yaml("enabled: true\ncount: 42\nratio: 3.14"),
        );
        let result = flatten(&rules, &configs);
        assert!(result.contains(&("CFG_ENABLED".into(), "true".into())));
        assert!(result.contains(&("CFG_COUNT".into(), "42".into())));
        assert!(result.contains(&("CFG_RATIO".into(), "3.14".into())));
    }

    // ── shell escaping ──────────────────────────────────────────────────

    #[test]
    fn shell_escape_plain_value() {
        assert_eq!(shell_escape("simple"), "simple");
        assert_eq!(shell_escape("/etc/kube/config"), "/etc/kube/config");
    }

    #[test]
    fn shell_escape_empty_value() {
        assert_eq!(shell_escape(""), "''");
    }

    #[test]
    fn shell_escape_spaces() {
        assert_eq!(shell_escape("hello world"), "'hello world'");
    }

    #[test]
    fn shell_escape_single_quotes() {
        assert_eq!(shell_escape("it's"), "'it'\\''s'");
    }

    #[test]
    fn shell_escape_special_chars() {
        assert_eq!(shell_escape("$HOME"), "'$HOME'");
        assert_eq!(shell_escape("a|b"), "'a|b'");
        assert_eq!(shell_escape("foo;bar"), "'foo;bar'");
        assert_eq!(shell_escape("a&b"), "'a&b'");
    }

    // ── emit_exports ────────────────────────────────────────────────────

    #[test]
    fn emit_exports_formatting() {
        let results = vec![
            ("KUBECONFIG".into(), "/etc/kube/config".into()),
            ("GREETING".into(), "hello world".into()),
            ("SIMPLE".into(), "42".into()),
        ];
        let output = emit_exports(&results);
        assert_eq!(
            output,
            "export KUBECONFIG=/etc/kube/config\nexport GREETING='hello world'\nexport SIMPLE=42\n"
        );
    }

    // ── end-to-end ──────────────────────────────────────────────────────

    #[test]
    fn end_to_end_parse_and_flatten() {
        let dc = yaml(
            r#"
            flatten:
              cluster.kubeconfig: KUBECONFIG
              cluster.context: KUBECTX_CURRENT_CONTEXT
              cloudflare.account_id: CF_ACCOUNT_ID
              cloudflare.*: CF_*
              tab.*: TAB_*
        "#,
        );

        let rules = parse_rules(&dc);

        let mut configs = HashMap::new();
        configs.insert(
            "cluster".into(),
            yaml("kubeconfig: /home/user/.kube/config\ncontext: my-cluster"),
        );
        configs.insert(
            "cloudflare".into(),
            yaml("account_id: abc123\nzone_id: zone456\napi_token: secret789"),
        );
        configs.insert(
            "tab".into(),
            yaml("project: myproj\nenv: staging"),
        );

        let result = flatten(&rules, &configs);

        // Check explicit rules
        assert!(result.contains(&("KUBECONFIG".into(), "/home/user/.kube/config".into())));
        assert!(result.contains(&("KUBECTX_CURRENT_CONTEXT".into(), "my-cluster".into())));
        assert!(result.contains(&("CF_ACCOUNT_ID".into(), "abc123".into())));

        // Check wildcard expansions
        assert!(result.contains(&("CF_ZONE_ID".into(), "zone456".into())));
        assert!(result.contains(&("CF_API_TOKEN".into(), "secret789".into())));
        assert!(result.contains(&("TAB_PROJECT".into(), "myproj".into())));
        assert!(result.contains(&("TAB_ENV".into(), "staging".into())));
    }
}
