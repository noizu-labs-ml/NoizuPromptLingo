use anyhow::Result;
use serde_yaml::Value;
use std::io::Read;
use std::path::Path;

pub fn run(
    name: &str,
    layer: Option<&str>,
    replace: bool,
    replace_key: Option<&str>,
    if_missing: bool,
    no_bump: bool,
) -> Result<()> {
    let cwd = std::env::current_dir()?;
    let store = crate::store::ensure_store(&cwd)?;
    crate::store::ensure_config(&store, name)?;

    let layer_name = layer.unwrap_or("base");
    let layer_file = crate::store::layout::layer_path(&store, name, layer_name);

    if if_missing && layer_file.exists() {
        return Ok(());
    }

    let mut stdin_buf = String::new();
    std::io::stdin().read_to_string(&mut stdin_buf)?;
    let input: Value = serde_yaml::from_str(&stdin_buf)?;

    // Separate 🔒-marked secret scalars (at any depth) from plain settings.
    let (plain, secrets) = crate::secret::split_secrets(&input);

    // Secrets require the AEAD key from settings.yaml — load it only when needed
    // so plain heredocs never depend on a configured key.
    let key = if secrets.is_empty() {
        None
    } else {
        Some(crate::settings::key()?)
    };

    apply(
        &store,
        name,
        layer_name,
        &plain,
        &secrets,
        key.as_ref(),
        replace,
        replace_key,
    )?;

    // Resolve active for this config
    crate::store::resolve::resolve_active(&store, name)?;
    crate::store::meta::update_configs_list(&store)?;

    if !no_bump {
        crate::store::bump_version(&store)?;
    }

    Ok(())
}

/// Write a parsed heredoc into the store: the plain (non-secret) portion goes to
/// the requested `layer`, while 🔒 secrets are encrypted and always merged into
/// the `secrets` layer regardless of the requested layer.
#[allow(clippy::too_many_arguments)]
pub(crate) fn apply(
    store: &Path,
    name: &str,
    layer_name: &str,
    plain: &Value,
    secrets: &[(String, crate::secret::ParsedSecret)],
    key: Option<&[u8; 32]>,
    replace: bool,
    replace_key: Option<&str>,
) -> Result<()> {
    crate::store::ensure_config(store, name)?;

    let plain_is_empty = matches!(plain, Value::Mapping(m) if m.is_empty());

    // Write the plain portion to the requested layer. Skip the write only when
    // the heredoc was *entirely* secrets, to avoid creating an empty `{}` file.
    if !plain_is_empty || secrets.is_empty() {
        let layer_file = crate::store::layout::layer_path(store, name, layer_name);
        write_layer(&layer_file, plain, replace, replace_key)?;
    }

    // 🔒 secrets → encrypted → secrets.yaml (always), deep-merged in.
    if !secrets.is_empty() {
        let key = key.ok_or_else(|| {
            anyhow::anyhow!("internal: encryption key required to store 🔒 secrets")
        })?;
        let enc_tree = crate::secret::build_encrypted_tree(secrets, key)?;
        let secrets_file = crate::store::layout::layer_path(store, name, "secrets");
        let existing = read_layer(&secrets_file);
        let merged = crate::yaml::merge::deep_merge(&existing, &enc_tree);
        std::fs::write(&secrets_file, serde_yaml::to_string(&merged)?)?;
    }

    Ok(())
}

fn read_layer(path: &Path) -> Value {
    if path.exists() {
        std::fs::read_to_string(path)
            .ok()
            .and_then(|c| serde_yaml::from_str(&c).ok())
            .unwrap_or_else(|| Value::Mapping(serde_yaml::Mapping::new()))
    } else {
        Value::Mapping(serde_yaml::Mapping::new())
    }
}

fn write_layer(layer_file: &Path, input: &Value, replace: bool, replace_key: Option<&str>) -> Result<()> {
    if replace {
        std::fs::write(layer_file, serde_yaml::to_string(input)?)?;
    } else if let Some(rk) = replace_key {
        // Replace just one branch: load existing, replace that key, write back.
        let mut existing = read_layer(layer_file);
        if let (Value::Mapping(ref mut emap), Value::Mapping(ref imap)) = (&mut existing, input) {
            let key_val = Value::String(rk.to_string());
            if let Some(new_val) = imap.get(&key_val) {
                emap.insert(key_val, new_val.clone());
            }
        }
        std::fs::write(layer_file, serde_yaml::to_string(&existing)?)?;
    } else {
        // Deep merge.
        let existing = read_layer(layer_file);
        let merged = crate::yaml::merge::deep_merge(&existing, input);
        std::fs::write(layer_file, serde_yaml::to_string(&merged)?)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    const KEY: [u8; 32] = [9u8; 32];

    fn ingest(store: &Path, name: &str, layer: &str, yaml: &str) {
        let input: Value = serde_yaml::from_str(yaml).unwrap();
        let (plain, secrets) = crate::secret::split_secrets(&input);
        apply(store, name, layer, &plain, &secrets, Some(&KEY), false, None).unwrap();
    }

    fn read(store: &Path, name: &str, layer: &str) -> Value {
        read_layer(&crate::store::layout::layer_path(store, name, layer))
    }

    #[test]
    fn mixed_heredoc_fans_out_base_and_secrets() {
        let tmp = TempDir::new().unwrap();
        let store = tmp.path();
        ingest(
            store,
            "cf",
            "base",
            "account_id: 123\naccess:\n  client_id: pub\n  client_secret: \"🔒 shh\"",
        );

        // Plain keys land in base.yaml; the secret leaf does not.
        let base = read(store, "cf", "base");
        assert_eq!(
            crate::yaml::path::get_path(&base, "account_id"),
            Some(Value::Number(123.into()))
        );
        assert_eq!(
            crate::yaml::path::get_path(&base, "access.client_id"),
            Some(Value::String("pub".into()))
        );
        assert!(crate::yaml::path::get_path(&base, "access.client_secret").is_none());

        // Secret lands encrypted in secrets.yaml.
        let secrets = read(store, "cf", "secrets");
        let tok = crate::yaml::path::get_path(&secrets, "access.client_secret").unwrap();
        let tok = tok.as_str().unwrap();
        assert!(crate::crypto::is_encrypted(tok));
        assert_eq!(crate::crypto::decode_token(tok, &KEY).unwrap().1, "shh");
    }

    #[test]
    fn all_secret_heredoc_creates_no_empty_base() {
        let tmp = TempDir::new().unwrap();
        let store = tmp.path();
        ingest(store, "cf", "base", "api_token: \"🔒 t\"");
        // base.yaml should not be created for an all-secret heredoc.
        assert!(!crate::store::layout::layer_path(store, "cf", "base").exists());
        assert!(crate::store::layout::layer_path(store, "cf", "secrets").exists());
    }

    #[test]
    fn replace_layer_does_not_wipe_unrelated_secrets() {
        let tmp = TempDir::new().unwrap();
        let store = tmp.path();
        // First seed a secret.
        ingest(store, "cf", "base", "api_token: \"🔒 first\"");
        // Now a --replace write of plain settings (with a new secret) must keep
        // merging secrets, not clobber the existing secret tree.
        let input: Value =
            serde_yaml::from_str("zone_id: z1\nother_secret: \"🔒 second\"").unwrap();
        let (plain, secrets) = crate::secret::split_secrets(&input);
        apply(store, "cf", "base", &plain, &secrets, Some(&KEY), true, None).unwrap();

        let secrets_layer = read(store, "cf", "secrets");
        // Both the original and the new secret survive.
        assert!(crate::yaml::path::get_path(&secrets_layer, "api_token").is_some());
        assert!(crate::yaml::path::get_path(&secrets_layer, "other_secret").is_some());
        // The base layer was replaced with just the plain settings.
        let base = read(store, "cf", "base");
        assert_eq!(
            crate::yaml::path::get_path(&base, "zone_id"),
            Some(Value::String("z1".into()))
        );
    }

    #[test]
    fn layer_secrets_with_padlock_both_target_secrets_file() {
        let tmp = TempDir::new().unwrap();
        let store = tmp.path();
        // Caller explicitly targets the secrets layer with a mix of plain + 🔒.
        ingest(store, "cf", "secrets", "plain_in_secrets: v\nenc: \"🔒 e\"");
        let secrets = read(store, "cf", "secrets");
        // Plain key written to secrets.yaml as-is (caller's explicit layer choice).
        assert_eq!(
            crate::yaml::path::get_path(&secrets, "plain_in_secrets"),
            Some(Value::String("v".into()))
        );
        // 🔒 value encrypted in the same file.
        let tok = crate::yaml::path::get_path(&secrets, "enc").unwrap();
        assert!(crate::crypto::is_encrypted(tok.as_str().unwrap()));
    }
}
