use anyhow::Result;
use rand::Rng;
use std::io::Write;

/// Resolve a config path to its *raw stored* scalar (which may be a `dcenc:`
/// token or the `⛔` restricted sentinel — callers decide how to handle it).
pub(crate) fn dc_lookup(name: &str, path: &str) -> Option<String> {
    let store = crate::store::find_current_store().ok()?;
    let chain = crate::store::resolve::resolve_chain(&store);
    let config = crate::store::resolve::resolve_config(&chain, name).ok()?;
    let val = crate::yaml::path::get_path(&config, path)?;
    match val {
        serde_yaml::Value::String(s) => Some(s.clone()),
        serde_yaml::Value::Number(n) => Some(n.to_string()),
        serde_yaml::Value::Bool(b) => Some(b.to_string()),
        serde_yaml::Value::Null => None,
        _ => Some(serde_yaml::to_string(&val).ok()?.trim().to_string()),
    }
}

/// Resolve a config path to its decrypted plaintext (internal API for
/// compare/push/infisical). Decrypts `dcenc:` tokens; passes plain values
/// through. Does NOT write an audit record — callers audit their own reveals.
pub(crate) fn get_secret_plaintext(name: &str, path: &str) -> anyhow::Result<Option<String>> {
    match dc_lookup(name, path) {
        None => Ok(None),
        Some(v) if crate::crypto::is_encrypted(&v) => {
            let key = crate::settings::key()?;
            let (_tier, pt) = crate::crypto::decode_token(&v, &key)?;
            Ok(Some(pt))
        }
        Some(v) => Ok(Some(v)),
    }
}

#[cfg(target_os = "macos")]
fn copy_to_clipboard(s: &str) -> anyhow::Result<()> {
    use std::io::Write as _;
    use std::process::{Command, Stdio};
    let mut child = Command::new("pbcopy").stdin(Stdio::piped()).spawn()?;
    child
        .stdin
        .as_mut()
        .ok_or_else(|| anyhow::anyhow!("failed to open pbcopy stdin"))?
        .write_all(s.as_bytes())?;
    child.wait()?;
    Ok(())
}

#[cfg(not(target_os = "macos"))]
fn copy_to_clipboard(_s: &str) -> anyhow::Result<()> {
    anyhow::bail!("--clippy is only supported on macOS (pbcopy)")
}

fn print_out(s: &str, raw: bool) {
    if raw {
        print!("{}", s);
    } else {
        println!("{}", s);
    }
}

/// Render a resolved scalar to stdout, applying redaction/reveal/clippy for
/// encrypted secrets and the `⛔` restricted sentinel. Plain values pass through.
#[allow(clippy::too_many_arguments)]
fn emit_value(
    name: &str,
    path: &str,
    val: &str,
    raw: bool,
    reveal: bool,
    clippy: bool,
    reveal_restricted: bool,
) -> Result<()> {
    // Restricted (⛔ shadowed) value — stricter than a normal secret.
    if crate::secret::is_restricted_sentinel(val) {
        if reveal_restricted || clippy {
            match crate::shadow::resolve(name, path)? {
                Some(plain) => {
                    crate::audit::record(name, path, 3, "reveal-restricted");
                    if clippy {
                        copy_to_clipboard(&plain)?;
                        eprintln!("dc: ⛔ restricted secret copied to clipboard");
                        return Ok(());
                    }
                    print_out(&plain, raw);
                    return Ok(());
                }
                None => anyhow::bail!(
                    "restricted secret {name}.{path} has no entry in the shadow store"
                ),
            }
        }
        crate::audit::record(name, path, 3, "redact-restricted-attempt");
        print_out("⛔ **restricted**", raw);
        return Ok(());
    }

    // Encrypted secret token.
    if crate::crypto::is_encrypted(val) {
        let tier = crate::crypto::token_tier(val).unwrap_or(0);
        if reveal || clippy {
            let key = crate::settings::key()?;
            let (_t, plain) = crate::crypto::decode_token(val, &key)?;
            if clippy {
                copy_to_clipboard(&plain)?;
                crate::audit::record(name, path, tier, "clippy");
                eprintln!("dc: 🔒 secret copied to clipboard");
                return Ok(());
            }
            crate::audit::record(name, path, tier, "reveal");
            print_out(&plain, raw);
            return Ok(());
        }
        // Default: redact without ever touching the key.
        print_out(&crate::secret::redaction_for(tier), raw);
        return Ok(());
    }

    // Plain (non-secret) value.
    print_out(val, raw);
    Ok(())
}

fn env_lookup(var: &str) -> Option<String> {
    std::env::var(var).ok().filter(|v| !v.is_empty())
}

fn auto_generate(gen_type: &str, length: usize) -> String {
    let mut rng = rand::thread_rng();
    match gen_type {
        "hex" => {
            let bytes: Vec<u8> = (0..length).map(|_| rng.gen()).collect();
            bytes.iter().map(|b| format!("{:02x}", b)).collect()
        }
        "password" | _ => {
            const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            (0..length)
                .map(|_| CHARSET[rng.gen_range(0..CHARSET.len())] as char)
                .collect()
        }
    }
}

fn persist_auto(env_var: &str, value: &str) {
    let store = match crate::store::find_current_store() {
        Ok(s) => s,
        Err(_) => return,
    };
    let meta = match crate::store::meta::read_meta(&store) {
        Ok(m) => m,
        Err(_) => return,
    };
    let auto_path = meta.source.join("secrets/.envrc.auto");
    if let Ok(contents) = std::fs::read_to_string(&auto_path) {
        if contents.contains(&format!("export {}=", env_var)) {
            return;
        }
    }
    if let Some(parent) = auto_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }
    if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(&auto_path) {
        let _ = writeln!(f, "export {}=\"{}\"", env_var, value);
    }
}

#[allow(clippy::too_many_arguments)]
pub fn run(
    name: &str,
    path: Option<&str>,
    raw: bool,
    override_var: Option<&str>,
    fallback_var: Option<&str>,
    auto: &[String],
    default: Option<&str>,
    reveal: bool,
    clippy: bool,
    reveal_restricted: bool,
) -> Result<()> {
    let env_var_name = override_var.or(fallback_var);

    // No path → dump whole config (original behavior)
    let Some(p) = path else {
        let store = crate::store::find_current_store()?;
        let chain = crate::store::resolve::resolve_chain(&store);
        let config = crate::store::resolve::resolve_config(&chain, name)?;
        print!("{}", serde_yaml::to_string(&config)?);
        return Ok(());
    };

    // Resolution: --override (ENV → dc) or --fallback (dc → ENV) or dc-only
    let resolved = if let Some(var) = override_var {
        env_lookup(var).or_else(|| dc_lookup(name, p))
    } else if let Some(var) = fallback_var {
        dc_lookup(name, p).or_else(|| env_lookup(var))
    } else {
        dc_lookup(name, p)
    };

    if let Some(val) = resolved {
        return emit_value(name, p, &val, raw, reveal, clippy, reveal_restricted);
    }

    // --auto: generate + persist to .envrc.auto
    if !auto.is_empty() {
        let gen_type = auto.first().map(|s| s.as_str()).unwrap_or("password");
        let length: usize = auto.get(1).and_then(|s| s.parse().ok()).unwrap_or(32);
        let val = auto_generate(gen_type, length);

        if let Some(var) = env_var_name {
            persist_auto(var, &val);
        }

        if raw { print!("{}", val); } else { println!("{}", val); }
        return Ok(());
    }

    // --default: static fallback
    if let Some(val) = default {
        if raw { print!("{}", val); } else { println!("{}", val); }
        return Ok(());
    }

    std::process::exit(1);
}
