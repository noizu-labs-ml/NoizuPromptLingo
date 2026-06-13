//! Parser + resolver for `.infisical-secrets.yaml` (apiVersion secrets-tools/v1).
//!
//! Maps Infisical secret NAMEs to their `dc:` lookup source and reproduces the
//! value-resolution precedence used by `infisical-populate-secrets`
//! (`ref → template → file → env → dc → fallback_dc → default`).

use anyhow::{anyhow, bail, Result};
use serde_yaml::Value;
use std::collections::BTreeMap;
use std::path::PathBuf;

#[derive(Debug, Clone, Default)]
pub struct SecretSpec {
    pub dc: Option<(String, String)>,
    pub fallback_dc: Option<(String, String)>,
    pub override_env: Option<String>,
    pub fallback_env: Option<String>,
    /// Parsed but not used during compare/resolve (we never auto-generate here).
    #[allow(dead_code)]
    pub auto: Option<Vec<String>>,
    pub default: Option<String>,
    pub env: Option<String>,
    pub file: Option<String>,
    pub decode: Option<String>,
    pub reference: Option<String>,
    pub template: Option<String>,
    /// Parsed for fidelity; optional-skip semantics are applied by callers.
    #[allow(dead_code)]
    pub optional: bool,
}

#[derive(Debug, Clone)]
pub struct Section {
    pub id: String,
    pub path: String,
    pub vars: Vec<(String, SecretSpec)>,
    pub secrets: Vec<(String, SecretSpec)>,
}

pub struct SecretsMap {
    pub sections: Vec<Section>,
}

fn split_dc(s: &str) -> Option<(String, String)> {
    let s = s.trim();
    let (cfg, path) = s.split_once(char::is_whitespace)?;
    Some((cfg.to_string(), path.trim().to_string()))
}

fn str_field(m: &serde_yaml::Mapping, k: &str) -> Option<String> {
    m.get(Value::String(k.to_string()))
        .and_then(|v| v.as_str())
        .map(|s| s.to_string())
}

fn parse_spec(v: &Value) -> SecretSpec {
    let Some(m) = v.as_mapping() else {
        return SecretSpec::default();
    };
    SecretSpec {
        dc: str_field(m, "dc").and_then(|s| split_dc(&s)),
        fallback_dc: str_field(m, "fallback_dc").and_then(|s| split_dc(&s)),
        override_env: str_field(m, "override"),
        fallback_env: str_field(m, "fallback"),
        auto: str_field(m, "auto").map(|s| s.split_whitespace().map(|x| x.to_string()).collect()),
        default: str_field(m, "default"),
        env: str_field(m, "env"),
        file: str_field(m, "file"),
        decode: str_field(m, "decode"),
        reference: str_field(m, "ref"),
        template: str_field(m, "template"),
        optional: m
            .get(Value::String("optional".to_string()))
            .and_then(|v| v.as_bool())
            .unwrap_or(false),
    }
}

fn parse_specs(v: Option<&Value>) -> Vec<(String, SecretSpec)> {
    let mut out = Vec::new();
    if let Some(Value::Mapping(m)) = v {
        for (k, val) in m {
            if let Some(name) = k.as_str() {
                out.push((name.to_string(), parse_spec(val)));
            }
        }
    }
    out
}

/// Parse a `.infisical-secrets.yaml` document (already-read string).
pub fn parse(content: &str) -> Result<SecretsMap> {
    let mut doc: Value = serde_yaml::from_str(content)?;
    doc.apply_merge().ok(); // resolve `<<: *anchor` merge keys
    let sections_val = doc
        .get("sections")
        .and_then(|v| v.as_sequence())
        .ok_or_else(|| anyhow!("`.infisical-secrets.yaml` has no `sections` list"))?;

    let mut sections = Vec::new();
    for s in sections_val {
        let id = s.get("id").and_then(|v| v.as_str()).unwrap_or("").to_string();
        let path = s.get("path").and_then(|v| v.as_str()).unwrap_or("").to_string();
        sections.push(Section {
            id,
            path,
            vars: parse_specs(s.get("vars")),
            secrets: parse_specs(s.get("secrets")),
        });
    }
    Ok(SecretsMap { sections })
}

/// Discover and load the secrets map.
pub fn load() -> Result<(PathBuf, SecretsMap)> {
    let path = discover()?;
    let content = std::fs::read_to_string(&path)?;
    Ok((path.clone(), parse(&content)?))
}

fn discover() -> Result<PathBuf> {
    if let Ok(p) = std::env::var("INFISICAL_SECRETS_FILE") {
        let pb = PathBuf::from(p);
        if pb.exists() {
            return Ok(pb);
        }
    }
    // Walk up from cwd.
    let mut dir = std::env::current_dir()?;
    loop {
        let cand = dir.join(".infisical-secrets.yaml");
        if cand.exists() {
            return Ok(cand);
        }
        if !dir.pop() {
            break;
        }
    }
    bail!("no .infisical-secrets.yaml found (set INFISICAL_SECRETS_FILE or run from the infra repo)")
}

impl SecretsMap {
    /// Find a `(section, spec)` by Infisical path + key.
    pub fn find_by_infisical_path(&self, path: &str, key: &str) -> Option<(&Section, &SecretSpec)> {
        let norm = |p: &str| format!("/{}", p.trim_matches('/'));
        let target = norm(path);
        for s in &self.sections {
            if norm(&s.path) == target {
                if let Some((_, spec)) = s.secrets.iter().find(|(n, _)| n == key) {
                    return Some((s, spec));
                }
            }
        }
        None
    }

    /// Find all `(section, name, spec)` matching a secret NAME (across sections).
    pub fn find_by_name(&self, name: &str) -> Vec<(&Section, &str, &SecretSpec)> {
        let mut out = Vec::new();
        for s in &self.sections {
            if let Some((n, spec)) = s.secrets.iter().find(|(n, _)| n == name) {
                out.push((s, n.as_str(), spec));
            }
        }
        out
    }
}

fn interpolate(template: &str, vars: &BTreeMap<String, String>) -> String {
    let mut out = String::new();
    let mut rest = template;
    while let Some(start) = rest.find("{{") {
        out.push_str(&rest[..start]);
        let after = &rest[start + 2..];
        if let Some(end) = after.find("}}") {
            let expr = after[..end].trim();
            let (var, filter) = match expr.split_once('|') {
                Some((v, f)) => (v.trim(), Some(f.trim())),
                None => (expr, None),
            };
            let val = vars.get(var).cloned().unwrap_or_default();
            let val = match filter {
                Some("urlencode") => urlencode(&val),
                _ => val,
            };
            out.push_str(&val);
            rest = &after[end + 2..];
        } else {
            out.push_str("{{");
            rest = after;
        }
    }
    out.push_str(rest);
    out
}

fn urlencode(s: &str) -> String {
    let mut out = String::new();
    for b in s.bytes() {
        match b {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => out.push(b as char),
            _ => out.push_str(&format!("%{:02X}", b)),
        }
    }
    out
}

/// Resolve a spec's value following the populate-secrets precedence.
/// `vars` holds already-resolved intermediate vars for this section.
pub fn resolve_local(spec: &SecretSpec, vars: &BTreeMap<String, String>) -> Result<Option<String>> {
    // 1. ref
    if let Some(r) = &spec.reference {
        return Ok(vars.get(r).cloned());
    }
    // 2. template
    if let Some(t) = &spec.template {
        return Ok(Some(interpolate(t, vars)));
    }
    // 3. file (override env wins, optional base64 decode)
    if let Some(f) = &spec.file {
        if let Some(ov) = &spec.override_env {
            if let Ok(v) = std::env::var(ov) {
                if !v.is_empty() {
                    return Ok(Some(v));
                }
            }
        }
        let raw = std::fs::read_to_string(f).unwrap_or_default();
        if spec.decode.as_deref() == Some("base64") {
            use base64::Engine;
            let decoded = base64::engine::general_purpose::STANDARD
                .decode(raw.trim())
                .map_err(|e| anyhow!("base64 decode of {f}: {e}"))?;
            return Ok(Some(String::from_utf8_lossy(&decoded).to_string()));
        }
        return Ok(Some(raw));
    }
    // 4. env
    if let Some(e) = &spec.env {
        if let Ok(v) = std::env::var(e) {
            if !v.is_empty() {
                return Ok(Some(v));
            }
        }
    }
    // 5. dc (override env wins; then dc; then fallback env; then default)
    if let Some((cfg, path)) = &spec.dc {
        if let Some(ov) = &spec.override_env {
            if let Ok(v) = std::env::var(ov) {
                if !v.is_empty() {
                    return Ok(Some(v));
                }
            }
        }
        if let Some(v) = crate::cmd::get::get_secret_plaintext(cfg, path)? {
            if !v.is_empty() {
                return Ok(Some(v));
            }
        }
        if let Some(fb) = &spec.fallback_env {
            if let Ok(v) = std::env::var(fb) {
                if !v.is_empty() {
                    return Ok(Some(v));
                }
            }
        }
    }
    // 6. fallback_dc
    if let Some((cfg, path)) = &spec.fallback_dc {
        if let Some(v) = crate::cmd::get::get_secret_plaintext(cfg, path)? {
            if !v.is_empty() {
                return Ok(Some(v));
            }
        }
    }
    // 7. default
    Ok(spec.default.clone())
}

/// Resolve all of a section's `vars` into a map (for ref/template use).
pub fn resolve_vars(section: &Section) -> BTreeMap<String, String> {
    let mut map = BTreeMap::new();
    for (name, spec) in &section.vars {
        if let Ok(Some(v)) = resolve_local(spec, &map) {
            map.insert(name.clone(), v);
        }
    }
    map
}

#[cfg(test)]
mod tests {
    use super::*;

    const DOC: &str = r#"
apiVersion: secrets-tools/v1
templates:
  smtp: &smtp
    SMTP_HOST: { dc: secrets smtp.host, override: SMTP_HOST }
sections:
  - id: data-postgres
    title: "PG"
    path: /data/postgres
    vars:
      _u: { default: penpot }
    secrets:
      PENPOT_DB_PASSWORD:
        dc: services design.penpot_db_password
        override: PENPOT_DB_PASSWORD
        auto: password 32
      URL:
        template: "postgres://{{_u}}:x@h/db"
      MAIL:
        <<: *smtp
"#;

    #[test]
    fn parses_sections_and_dc_split() {
        let map = parse(DOC).unwrap();
        let (sec, spec) = map
            .find_by_infisical_path("/data/postgres", "PENPOT_DB_PASSWORD")
            .unwrap();
        assert_eq!(sec.id, "data-postgres");
        assert_eq!(spec.dc, Some(("services".into(), "design.penpot_db_password".into())));
        assert_eq!(spec.override_env.as_deref(), Some("PENPOT_DB_PASSWORD"));
        assert_eq!(spec.auto, Some(vec!["password".into(), "32".into()]));
    }

    #[test]
    fn resolves_template_with_vars() {
        let map = parse(DOC).unwrap();
        let sec = map.sections.iter().find(|s| s.id == "data-postgres").unwrap();
        let vars = resolve_vars(sec);
        let (_, spec) = sec.secrets.iter().find(|(n, _)| n == "URL").unwrap();
        let v = resolve_local(spec, &vars).unwrap().unwrap();
        assert_eq!(v, "postgres://penpot:x@h/db");
    }

    #[test]
    fn find_by_name_across_sections() {
        let map = parse(DOC).unwrap();
        let hits = map.find_by_name("PENPOT_DB_PASSWORD");
        assert_eq!(hits.len(), 1);
        assert_eq!(hits[0].0.path, "/data/postgres");
    }

    #[test]
    fn urlencode_filter() {
        let mut vars = BTreeMap::new();
        vars.insert("p".to_string(), "a/b@c".to_string());
        assert_eq!(interpolate("{{p|urlencode}}", &vars), "a%2Fb%40c");
    }
}
