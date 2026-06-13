//! Secret marking scheme and the split-and-encrypt walker.
//!
//! A YAML scalar is a *secret* when its trimmed content begins with the padlock
//! `🔒`. An optional run of `❗` immediately after the padlock sets the
//! sensitivity tier (low/med/high → 1/2/3). `⛔` is reserved for shadowed
//! ("locked-down") values and is handled by [`crate::shadow`], not here.
//!
//! Parsing rule (per spec): trim the whole scalar → require leading `🔒` →
//! consume an optional `❗` run (tier) → trim leading/trailing whitespace and
//! newlines of the remaining body, preserving interior whitespace/newlines.

use serde_yaml::Value;

pub const PADLOCK: char = '🔒';
pub const BANG: char = '❗';
pub const RESTRICTED: char = '⛔';

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParsedSecret {
    /// Sensitivity tier 0..=3 (0 = unmarked secret, 3 = highest).
    pub tier: u8,
    /// The secret body with marker/tier stripped and ends trimmed.
    pub body: String,
}

/// Detect and strip a `🔒` secret marker. Returns `None` if `raw` is not a secret.
pub fn parse_marker(raw: &str) -> Option<ParsedSecret> {
    let trimmed = raw.trim();
    let after_lock = trimmed.strip_prefix(PADLOCK)?;
    let mut rest = after_lock.trim_start();
    let mut tier: u8 = 0;
    while let Some(r) = rest.strip_prefix(BANG) {
        if tier < 3 {
            tier += 1;
        }
        rest = r;
    }
    let body = rest.trim().to_string();
    Some(ParsedSecret { tier, body })
}

/// True if the scalar is the `⛔` shadowed-secret sentinel.
pub fn is_restricted_sentinel(raw: &str) -> bool {
    raw.trim() == RESTRICTED.to_string()
}

/// Redaction placeholder shown in place of a secret value, annotated by tier.
pub fn redaction_for(tier: u8) -> String {
    let bangs: String = std::iter::repeat(BANG).take(tier.min(3) as usize).collect();
    format!("{PADLOCK}{bangs} **redacted**")
}

/// Split an ingested YAML tree into a plain (non-secret) tree and a list of
/// `(dot-path, ParsedSecret)` entries for every `🔒`-marked scalar at any depth.
pub fn split_secrets(input: &Value) -> (Value, Vec<(String, ParsedSecret)>) {
    let mut secrets = Vec::new();
    let plain = walk_split(input, "", &mut secrets)
        .unwrap_or_else(|| Value::Mapping(serde_yaml::Mapping::new()));
    (plain, secrets)
}

fn walk_split(val: &Value, prefix: &str, out: &mut Vec<(String, ParsedSecret)>) -> Option<Value> {
    match val {
        Value::Mapping(m) => {
            let mut plain = serde_yaml::Mapping::new();
            for (k, v) in m {
                let key_str = k.as_str().unwrap_or_default();
                let path = if prefix.is_empty() {
                    key_str.to_string()
                } else {
                    format!("{}.{}", prefix, key_str)
                };
                if let Some(child) = walk_split(v, &path, out) {
                    plain.insert(k.clone(), child);
                }
            }
            // Drop a map entirely from the plain tree only if it originally had
            // children and all of them were secrets.
            if plain.is_empty() && !m.is_empty() {
                None
            } else {
                Some(Value::Mapping(plain))
            }
        }
        Value::String(s) => match parse_marker(s) {
            Some(ps) => {
                out.push((prefix.to_string(), ps));
                None
            }
            None => Some(val.clone()),
        },
        other => Some(other.clone()),
    }
}

/// Build a YAML subtree holding each secret encrypted into a `dcenc:v1` token,
/// keyed by its dot-path. Suitable for deep-merging into a `secrets.yaml` layer.
pub fn build_encrypted_tree(
    secrets: &[(String, ParsedSecret)],
    key: &[u8; 32],
) -> anyhow::Result<Value> {
    let mut tree = Value::Mapping(serde_yaml::Mapping::new());
    for (path, ps) in secrets {
        // If the marked body is *already* an encrypted token (e.g. a secret
        // stored encrypted-at-rest inline in an `.envrc`), store it verbatim
        // rather than double-encrypting it.
        let token = if crate::crypto::is_encrypted(&ps.body) {
            ps.body.clone()
        } else {
            crate::crypto::encode_token(&ps.body, ps.tier, key)?
        };
        crate::yaml::path::set_path(&mut tree, path, Value::String(token))?;
    }
    Ok(tree)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_spec_example_trim() {
        // Mirrors the spec's `|` block-scalar example.
        let raw = " 🔒 adfslkjasldfkjaldfkjaslkfjsa            s\n  \n d\n";
        let ps = parse_marker(raw).unwrap();
        assert_eq!(ps.tier, 0);
        assert_eq!(ps.body, "adfslkjasldfkjaldfkjaslkfjsa            s\n  \n d");
    }

    #[test]
    fn parses_sensitivity_tiers() {
        assert_eq!(parse_marker("🔒❗ low").unwrap().tier, 1);
        assert_eq!(parse_marker("🔒❗❗ med").unwrap().tier, 2);
        assert_eq!(parse_marker("🔒❗❗❗ high").unwrap().tier, 3);
        // caps at 3, extra bangs consumed
        assert_eq!(parse_marker("🔒❗❗❗❗ capped").unwrap().tier, 3);
        assert_eq!(parse_marker("🔒❗❗❗❗ capped").unwrap().body, "capped");
    }

    #[test]
    fn non_secret_returns_none() {
        assert!(parse_marker("just a setting").is_none());
        assert!(parse_marker("  plain  ").is_none());
    }

    #[test]
    fn redaction_reflects_tier() {
        assert_eq!(redaction_for(0), "🔒 **redacted**");
        assert_eq!(redaction_for(2), "🔒❗❗ **redacted**");
    }

    #[test]
    fn split_separates_plain_and_secret_at_depth() {
        let input: Value = serde_yaml::from_str(
            "account_id: 12345\naccess:\n  client_id: pub\n  client_secret: \"🔒 shh\"\ntoken: \"🔒❗❗ topsecret\"",
        )
        .unwrap();
        let (plain, secrets) = split_secrets(&input);

        // plain keeps non-secret values, drops the secret leaves
        assert_eq!(
            crate::yaml::path::get_path(&plain, "account_id"),
            Some(Value::Number(12345.into()))
        );
        assert_eq!(
            crate::yaml::path::get_path(&plain, "access.client_id"),
            Some(Value::String("pub".into()))
        );
        assert!(crate::yaml::path::get_path(&plain, "access.client_secret").is_none());
        assert!(crate::yaml::path::get_path(&plain, "token").is_none());

        // secrets collected with full dot-paths and tiers
        assert!(secrets
            .iter()
            .any(|(p, s)| p == "access.client_secret" && s.body == "shh" && s.tier == 0));
        assert!(secrets
            .iter()
            .any(|(p, s)| p == "token" && s.body == "topsecret" && s.tier == 2));
    }

    #[test]
    fn map_with_only_secrets_is_dropped_from_plain() {
        let input: Value =
            serde_yaml::from_str("creds:\n  password: \"🔒 p\"\n  api: \"🔒 a\"").unwrap();
        let (plain, secrets) = split_secrets(&input);
        assert!(crate::yaml::path::get_path(&plain, "creds").is_none());
        assert_eq!(secrets.len(), 2);
    }

    #[test]
    fn encrypted_tree_round_trips_through_paths() {
        let key = [7u8; 32];
        let secrets = vec![(
            "access.client_secret".to_string(),
            ParsedSecret { tier: 1, body: "shh".into() },
        )];
        let tree = build_encrypted_tree(&secrets, &key).unwrap();
        let tok = crate::yaml::path::get_path(&tree, "access.client_secret").unwrap();
        let tok = tok.as_str().unwrap();
        assert!(crate::crypto::is_encrypted(tok));
        let (tier, body) = crate::crypto::decode_token(tok, &key).unwrap();
        assert_eq!(tier, 1);
        assert_eq!(body, "shh");
    }
}
