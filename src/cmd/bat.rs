//! `dc bat` — browse/search config entries with secrets masked.
//!
//! Renders resolved config as YAML with `dcenc:` secrets replaced by a tiered
//! redaction placeholder (unless `--reveal`) and `⛔` shadowed values always
//! masked. Supports regex include/exclude filters on the full concatenated key
//! path (e.g. `cf.access.client_secret`) and on the value. Output is piped to
//! `bat` when available, else printed plainly.

use anyhow::{anyhow, Result};
use regex::Regex;
use serde_yaml::{Mapping, Value};
use std::io::Write;

struct Filters {
    filter_key: Option<Regex>,
    filter_value: Option<Regex>,
    exclude_key: Option<Regex>,
    exclude_value: Option<Regex>,
}

impl Filters {
    fn compile(
        fk: Option<&str>,
        fv: Option<&str>,
        ek: Option<&str>,
        ev: Option<&str>,
    ) -> Result<Self> {
        let c = |o: Option<&str>| -> Result<Option<Regex>> {
            match o {
                Some(p) => Ok(Some(Regex::new(p).map_err(|e| anyhow!("bad regex '{p}': {e}"))?)),
                None => Ok(None),
            }
        };
        Ok(Filters {
            filter_key: c(fk)?,
            filter_value: c(fv)?,
            exclude_key: c(ek)?,
            exclude_value: c(ev)?,
        })
    }

    fn passes(&self, key: &str, val: &str) -> bool {
        if let Some(re) = &self.filter_key {
            if !re.is_match(key) {
                return false;
            }
        }
        if let Some(re) = &self.filter_value {
            if !re.is_match(val) {
                return false;
            }
        }
        if let Some(re) = &self.exclude_key {
            if re.is_match(key) {
                return false;
            }
        }
        if let Some(re) = &self.exclude_value {
            if re.is_match(val) {
                return false;
            }
        }
        true
    }
}

/// Mask a string leaf. Returns `(display_value, match_string, Some(tier))` where
/// `Some(tier)` is set only when an encrypted secret was actually decrypted
/// (i.e. a real reveal that should be audited).
fn mask_string(raw: &str, reveal: bool, key: Option<&[u8; 32]>) -> (Value, String, Option<u8>) {
    if crate::secret::is_restricted_sentinel(raw) {
        let d = "⛔ **restricted**".to_string();
        return (Value::String(d.clone()), d, None); // bat never reveals ⛔
    }
    if crate::crypto::is_encrypted(raw) {
        let tier = crate::crypto::token_tier(raw).unwrap_or(0);
        if reveal {
            if let Some(k) = key {
                if let Ok((_t, plain)) = crate::crypto::decode_token(raw, k) {
                    return (Value::String(plain.clone()), plain, Some(tier));
                }
            }
        }
        let r = crate::secret::redaction_for(tier);
        return (Value::String(r.clone()), r, None);
    }
    (Value::String(raw.to_string()), raw.to_string(), None)
}

/// Recursively render `val` into a filtered/masked tree. `prefix` is the full
/// concatenated key path used for key-regex matching and audit records.
fn render(
    prefix: &str,
    val: &Value,
    f: &Filters,
    reveal: bool,
    key: Option<&[u8; 32]>,
) -> Option<Value> {
    match val {
        Value::Mapping(m) => {
            let mut out = Mapping::new();
            for (k, v) in m {
                let ks = k.as_str().unwrap_or_default();
                if ks.starts_with('_') {
                    continue; // skip internal markers like _dc_pruned
                }
                let child_prefix = if prefix.is_empty() {
                    ks.to_string()
                } else {
                    format!("{prefix}.{ks}")
                };
                if let Some(child) = render(&child_prefix, v, f, reveal, key) {
                    out.insert(k.clone(), child);
                }
            }
            if out.is_empty() {
                None
            } else {
                Some(Value::Mapping(out))
            }
        }
        Value::Sequence(seq) => {
            let mut out = Vec::new();
            for (i, item) in seq.iter().enumerate() {
                let cp = format!("{prefix}[{i}]");
                if let Some(r) = render(&cp, item, f, reveal, key) {
                    out.push(r);
                }
            }
            if out.is_empty() {
                None
            } else {
                Some(Value::Sequence(out))
            }
        }
        scalar => {
            let (display, match_val, sec) = match scalar {
                Value::String(s) => mask_string(s, reveal, key),
                Value::Number(n) => (scalar.clone(), n.to_string(), None),
                Value::Bool(b) => (scalar.clone(), b.to_string(), None),
                Value::Null => (scalar.clone(), String::new(), None),
                _ => (scalar.clone(), String::new(), None),
            };
            if !f.passes(prefix, &match_val) {
                return None;
            }
            if let Some(tier) = sec {
                let (subj, rel) = prefix.split_once('.').unwrap_or((prefix, ""));
                crate::audit::record(subj, rel, tier, "bat");
            }
            Some(display)
        }
    }
}

fn all_config_names(chain: &[std::path::PathBuf]) -> Vec<String> {
    let mut names: Vec<String> = Vec::new();
    for s in chain {
        if let Ok(meta) = crate::store::meta::read_meta(s) {
            for c in meta.configs {
                if !c.starts_with('_') && !names.contains(&c) {
                    names.push(c);
                }
            }
        }
    }
    names.sort();
    names
}

fn output(text: &str) {
    use std::process::{Command, Stdio};
    let spawned = Command::new("bat")
        .args(["--language", "yaml", "--style=plain", "--paging=never"])
        .stdin(Stdio::piped())
        .spawn();
    match spawned {
        Ok(mut child) => {
            if let Some(si) = child.stdin.as_mut() {
                let _ = si.write_all(text.as_bytes());
            }
            let _ = child.wait();
        }
        Err(_) => print!("{}", text),
    }
}

#[allow(clippy::too_many_arguments)]
pub fn run(
    subject: Option<&str>,
    scope: Option<&str>,
    all: bool,
    reveal: bool,
    filter_key: Option<&str>,
    filter_value: Option<&str>,
    exclude_key: Option<&str>,
    exclude_value: Option<&str>,
) -> Result<()> {
    let filters = Filters::compile(filter_key, filter_value, exclude_key, exclude_value)?;
    let store = crate::store::find_current_store()?;
    let chain = crate::store::resolve::resolve_chain(&store);
    let key = if reveal { crate::settings::key().ok() } else { None };

    if all {
        let mut root = Mapping::new();
        for name in all_config_names(&chain) {
            let cfg = crate::store::resolve::resolve_config(&chain, &name)?;
            if let Some(masked) = render(&name, &cfg, &filters, reveal, key.as_ref()) {
                root.insert(Value::String(name), masked);
            }
        }
        let text = serde_yaml::to_string(&Value::Mapping(root))?;
        output(&text);
        return Ok(());
    }

    let name = subject.ok_or_else(|| anyhow!("usage: dc bat [--all | <subject> [<scope>]]"))?;
    let cfg = crate::store::resolve::resolve_config(&chain, name)?;

    if let Some(sc) = scope {
        let target = crate::yaml::path::get_path(&cfg, sc)
            .ok_or_else(|| anyhow!("path '{sc}' not found in '{name}'"))?;
        let prefix = format!("{name}.{sc}");
        match render(&prefix, &target, &filters, reveal, key.as_ref()) {
            Some(masked) => {
                let text = format!("# {prefix}\n{}", serde_yaml::to_string(&masked)?);
                output(&text);
            }
            None => println!("# {prefix} (no entries matched)"),
        }
    } else {
        let mut root = Mapping::new();
        if let Some(masked) = render(name, &cfg, &filters, reveal, key.as_ref()) {
            root.insert(Value::String(name.to_string()), masked);
        }
        let text = serde_yaml::to_string(&Value::Mapping(root))?;
        output(&text);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const KEY: [u8; 32] = [3u8; 32];

    fn enc(body: &str, tier: u8) -> String {
        crate::crypto::encode_token(body, tier, &KEY).unwrap()
    }

    fn no_filters() -> Filters {
        Filters::compile(None, None, None, None).unwrap()
    }

    #[test]
    fn masks_secret_by_default() {
        let mut m = Mapping::new();
        m.insert("client_id".into(), Value::String("pub".into()));
        m.insert("client_secret".into(), Value::String(enc("shh", 2)));
        let val = Value::Mapping(m);
        let out = render("cf.access", &val, &no_filters(), false, None).unwrap();
        assert_eq!(
            crate::yaml::path::get_path(&out, "client_id"),
            Some(Value::String("pub".into()))
        );
        assert_eq!(
            crate::yaml::path::get_path(&out, "client_secret"),
            Some(Value::String("🔒❗❗ **redacted**".into()))
        );
    }

    #[test]
    fn reveals_secret_with_key() {
        let mut m = Mapping::new();
        m.insert("client_secret".into(), Value::String(enc("shh", 0)));
        let val = Value::Mapping(m);
        let out = render("cf.access", &val, &no_filters(), true, Some(&KEY)).unwrap();
        assert_eq!(
            crate::yaml::path::get_path(&out, "client_secret"),
            Some(Value::String("shh".into()))
        );
    }

    #[test]
    fn restricted_always_masked_even_with_reveal() {
        let mut m = Mapping::new();
        m.insert("locked".into(), Value::String("⛔".into()));
        let val = Value::Mapping(m);
        let out = render("cf", &val, &no_filters(), true, Some(&KEY)).unwrap();
        assert_eq!(
            crate::yaml::path::get_path(&out, "locked"),
            Some(Value::String("⛔ **restricted**".into()))
        );
    }

    #[test]
    fn filter_key_keeps_only_matching() {
        let mut m = Mapping::new();
        m.insert("password".into(), Value::String("p".into()));
        m.insert("host".into(), Value::String("h".into()));
        let val = Value::Mapping(m);
        let f = Filters::compile(Some("password$"), None, None, None).unwrap();
        let out = render("db", &val, &f, false, None).unwrap();
        assert!(crate::yaml::path::get_path(&out, "password").is_some());
        assert!(crate::yaml::path::get_path(&out, "host").is_none());
    }

    #[test]
    fn exclude_key_drops_matching_full_path() {
        let mut inner = Mapping::new();
        inner.insert("password".into(), Value::String("p".into()));
        inner.insert("user".into(), Value::String("u".into()));
        let mut m = Mapping::new();
        m.insert("replica".into(), Value::Mapping(inner));
        let val = Value::Mapping(m);
        // exclude on the concatenated path
        let f = Filters::compile(None, None, Some(r"replica\.password"), None).unwrap();
        let out = render("timescale", &val, &f, false, None).unwrap();
        assert!(crate::yaml::path::get_path(&out, "replica.user").is_some());
        assert!(crate::yaml::path::get_path(&out, "replica.password").is_none());
    }

    #[test]
    fn exclude_value_matches_redaction_when_not_revealed() {
        let mut m = Mapping::new();
        m.insert("a".into(), Value::String(enc("x", 0)));
        m.insert("b".into(), Value::String("plain".into()));
        let val = Value::Mapping(m);
        // redaction string contains "redacted"; exclude it → only plain remains
        let f = Filters::compile(None, None, None, Some("redacted")).unwrap();
        let out = render("cfg", &val, &f, false, None).unwrap();
        assert!(crate::yaml::path::get_path(&out, "a").is_none());
        assert_eq!(
            crate::yaml::path::get_path(&out, "b"),
            Some(Value::String("plain".into()))
        );
    }
}
