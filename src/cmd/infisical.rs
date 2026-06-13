//! `dc infisical …` — secrets-map-driven compare/get/set against Infisical.
//!
//! Compare (G) lives here now; get/set roundtripping (I) is added in a later
//! milestone.

use anyhow::{anyhow, Result};

fn split_path_key(infisical_path: &str) -> Result<(String, String)> {
    let (path, key) = infisical_path
        .trim_start_matches('/')
        .rsplit_once('/')
        .ok_or_else(|| anyhow!("expected <path>/<NAME>, got `{infisical_path}`"))?;
    Ok((format!("/{}", path.trim_matches('/')), key.to_string()))
}

/// `dc infisical compare <infisical-path> --to …` — resolve the local value via
/// the `.infisical-secrets.yaml` mapping, then compare to the targets.
pub fn compare(infisical_path: &str, tos: &[String]) -> Result<()> {
    if tos.is_empty() {
        return Err(anyhow!("provide at least one --to <target>"));
    }
    let (_file, map) = crate::secretsmap::load()?;
    let (path, key) = split_path_key(infisical_path)?;
    let (section, spec) = map
        .find_by_infisical_path(&path, &key)
        .ok_or_else(|| anyhow!("no mapping for {path}/{key} in .infisical-secrets.yaml"))?;
    let vars = crate::secretsmap::resolve_vars(section);
    let local = crate::secretsmap::resolve_local(spec, &vars)?
        .ok_or_else(|| anyhow!("local value for {key} resolved empty"))?;
    crate::audit::record(&section.id, &key, 0, "infisical-compare");

    let all_equal = crate::cmd::compare::compare_local_to_targets(&local, tos)?;
    if !all_equal {
        std::process::exit(1);
    }
    Ok(())
}

fn mask(s: &str) -> String {
    let chars: Vec<char> = s.chars().collect();
    let n = chars.len();
    if n <= 4 {
        "••••".to_string()
    } else {
        format!(
            "{}••••{}",
            chars[..2].iter().collect::<String>(),
            chars[n - 2..].iter().collect::<String>()
        )
    }
}

fn fetch_live(path: &str, key: &str) -> Option<String> {
    let cfg = crate::infisical::InfisicalConfig::resolve(None).ok()?;
    let client = crate::infisical::Client::login(cfg).ok()?;
    client.get_secret(path, key).ok().flatten()
}

/// `dc infisical get "<NAME>"` — fetch the live Infisical value, locate the
/// secrets-map mapping + dc source, and present both (redacted unless --reveal).
pub fn get(name: &str, reveal: bool) -> Result<()> {
    let (_file, map) = crate::secretsmap::load()?;
    let hits = map.find_by_name(name);
    if hits.is_empty() {
        return Err(anyhow!("no Infisical mapping named `{name}`"));
    }
    for (section, key, spec) in hits {
        let vars = crate::secretsmap::resolve_vars(section);
        let local = crate::secretsmap::resolve_local(spec, &vars).ok().flatten();
        let live = fetch_live(&section.path, key);
        let dc_src = spec
            .dc
            .as_ref()
            .map(|(c, p)| format!("{c} {p}"))
            .unwrap_or_else(|| "(non-dc)".to_string());

        let eq = match (&local, &live) {
            (Some(l), Some(r)) => Some(crate::secretcmp::eq_ct(l.as_bytes(), r.as_bytes())),
            _ => None,
        };
        let match_str = match eq {
            Some(true) => "==",
            Some(false) => "!=",
            None => "?",
        };

        if reveal {
            crate::audit::record(&section.id, key, 0, "infisical-get");
            println!(
                "{}/{}  infisical={}  dc[{}]={}  match={}",
                section.path,
                key,
                live.as_deref().unwrap_or("<missing>"),
                dc_src,
                local.as_deref().unwrap_or("<none>"),
                match_str
            );
        } else {
            println!(
                "{}/{}  infisical={}  dc[{}]={}  match={}",
                section.path,
                key,
                live.as_deref().map(mask).unwrap_or_else(|| "<missing>".to_string()),
                dc_src,
                local.as_deref().map(mask).unwrap_or_else(|| "<none>".to_string()),
                match_str
            );
        }
    }
    Ok(())
}

/// `dc infisical set "<NAME>" …` — locate where the dc secret is set and edit it
/// in place (reuses the `dc config set` machinery).
pub fn set(
    name: &str,
    value: Option<&str>,
    from: Option<&str>,
    stdin: bool,
    encrypted: bool,
    yes: bool,
) -> Result<()> {
    let (_file, map) = crate::secretsmap::load()?;
    let hits = map.find_by_name(name);
    let dc_hits: Vec<_> = hits.iter().filter(|(_, _, s)| s.dc.is_some()).collect();
    if dc_hits.is_empty() {
        return Err(anyhow!("`{name}` is not dc-backed — nothing to set"));
    }
    if dc_hits.len() > 1 {
        eprintln!("`{name}` is mapped in multiple sections:");
        for (sec, _, spec) in &dc_hits {
            if let Some((c, p)) = &spec.dc {
                eprintln!("  {} → dc {c} {p}", sec.path);
            }
        }
        return Err(anyhow!("ambiguous — edit the dc source directly"));
    }
    let (_section, _key, spec) = dc_hits[0];
    let (cfg, path) = spec.dc.clone().unwrap();
    // Delegate to the config edit-in-place machinery.
    crate::cmd::config::set(&cfg, &path, value, from, stdin, encrypted, yes)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn masks_values() {
        assert_eq!(mask("abc"), "••••");
        assert_eq!(mask("abcdefgh"), "ab••••gh");
    }

    #[test]
    fn splits_path_and_key() {
        assert_eq!(
            split_path_key("/data/postgres/POSTGRES_PASSWORD").unwrap(),
            ("/data/postgres".to_string(), "POSTGRES_PASSWORD".to_string())
        );
        assert_eq!(
            split_path_key("apps/ghost/MAIL").unwrap(),
            ("/apps/ghost".to_string(), "MAIL".to_string())
        );
        assert!(split_path_key("NOPATH").is_err());
    }
}
