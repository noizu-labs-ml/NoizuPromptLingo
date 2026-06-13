use anyhow::Result;
use std::collections::HashMap;

use crate::api::SetSecretOutcome;
use crate::cli::PopulateArgs;
use crate::config::{SecretsConfig, discover_config};
use crate::engine::resolve;
use crate::tui::populate_view::{PopulateEvent, PopulateOutcome, print_event};

use super::creds;

pub async fn run(args: PopulateArgs) -> Result<()> {
    let env = args.env_flags.resolve();
    let config_path = discover_config(args.config.config.as_deref())?;

    eprintln!("Config: {}", config_path.display());
    eprintln!("Environment: {env}");

    let config = SecretsConfig::load(&config_path)?;

    let sections = match &config {
        SecretsConfig::V1(cfg) => {
            if args.list {
                println!("Sections:");
                for s in &cfg.sections {
                    println!("  {} — {}", s.id, s.title);
                }
                println!("\nGroups:");
                for (name, ids) in &cfg.groups {
                    println!("  {} → [{}]", name, ids.join(", "));
                }
                return Ok(());
            }

            // Filter to section/group if specified
            if let Some(filter) = &args.section {
                // Try as group first
                if let Some(group_sections) = cfg.resolve_group(filter) {
                    group_sections.iter().map(|s| (*s).clone()).collect::<Vec<_>>()
                } else if let Some(section) = cfg.section(filter) {
                    vec![section.clone()]
                } else {
                    anyhow::bail!("Section or group '{}' not found", filter);
                }
            } else {
                cfg.sections.clone()
            }
        }
        SecretsConfig::Legacy(cfg) => {
            return run_legacy(cfg, &env, args.dry_run, args.show_secrets, args.impacted).await;
        }
    };

    let client = creds::build_client(&env).await?;

    // Ensure all folder paths exist first
    for section in &sections {
        client.ensure_folder(&section.path).await?;
    }

    // Process each section
    for section in &sections {
        eprintln!("\n[{}] {} → {}", section.id, section.title, section.path);

        // Phase A: resolve vars
        let mut resolved_vars: HashMap<String, String> = HashMap::new();
        for (name, spec) in &section.vars {
            match resolve::resolve_spec(spec, &resolved_vars)? {
                Some(val) => { resolved_vars.insert(name.clone(), val); }
                None if !spec.optional => {
                    eprintln!("  WARN: var '{name}' resolved to nothing");
                }
                None => {}
            }
        }

        // Phase B: process secrets
        for (name, spec) in &section.secrets {
            let value = match resolve::resolve_spec(spec, &resolved_vars)? {
                Some(v) => v,
                None => {
                    if !spec.optional {
                        let event = PopulateEvent {
                            name: name.clone(),
                            path: section.path.clone(),
                            outcome: PopulateOutcome::Error("value resolved to None".into()),
                        };
                        print_event(&event);
                    }
                    continue;
                }
            };

            let outcome_raw = client
                .set_secret(&section.path, name, &value, args.dry_run)
                .await;

            let outcome = match outcome_raw {
                Ok(SetSecretOutcome::Created) => PopulateOutcome::Created,
                Ok(SetSecretOutcome::Updated) => PopulateOutcome::Updated,
                Ok(SetSecretOutcome::Unchanged) => PopulateOutcome::Unchanged,
                Ok(SetSecretOutcome::WouldCreate) => PopulateOutcome::Created,
                Ok(SetSecretOutcome::WouldUpdate) => PopulateOutcome::Updated,
                Err(e) => PopulateOutcome::Error(e.to_string()),
            };

            // Skip unchanged if --impacted
            if args.impacted && outcome == PopulateOutcome::Unchanged {
                continue;
            }

            let event = PopulateEvent {
                name: name.clone(),
                path: section.path.clone(),
                outcome,
            };
            print_event(&event);
        }
    }

    Ok(())
}

async fn run_legacy(
    cfg: &crate::config::legacy::SecretsConfigLegacy,
    env: &str,
    dry_run: bool,
    _show_secrets: bool,
    impacted: bool,
) -> Result<()> {
    let client = creds::build_client(env).await?;

    // Staging: copy all values from prod
    if env == "staging" || env == "stage" {
        let prod_client = creds::build_client("prod").await?;
        for folder in &cfg.folders {
            let secrets = prod_client.list_secrets(folder).await?;
            for s in secrets {
                let outcome = client.set_secret(folder, &s.key, &s.value, dry_run).await?;
                let event = PopulateEvent {
                    name: s.key.clone(),
                    path: folder.clone(),
                    outcome: outcome_to_populate(outcome),
                };
                if !impacted || event.outcome != PopulateOutcome::Unchanged {
                    print_event(&event);
                }
            }
        }
        return Ok(());
    }

    // Resolve variables
    let mut resolved: HashMap<String, String> = HashMap::new();
    for (name, spec) in &cfg.variables {
        let val = resolve_legacy_var(spec, &resolved)?;
        if let Some(v) = val {
            resolved.insert(name.clone(), v);
        }
    }

    // Ensure folders
    for folder in &cfg.folders {
        client.ensure_folder(folder).await?;
    }

    // Apply mappings
    for (folder, key_map) in &cfg.mappings {
        for (key, var_ref) in key_map {
            // "?VAR_NAME" prefix means optional
            let (optional, var_name) = if var_ref.starts_with('?') {
                (true, &var_ref[1..])
            } else {
                (false, var_ref.as_str())
            };

            let value = match resolved.get(var_name) {
                Some(v) => v.clone(),
                None => {
                    if optional {
                        continue;
                    }
                    eprintln!("  ERROR: variable '{var_name}' not resolved for {folder}/{key}");
                    continue;
                }
            };

            let outcome = client.set_secret(folder, key, &value, dry_run).await?;
            let event = PopulateEvent {
                name: key.clone(),
                path: folder.clone(),
                outcome: outcome_to_populate(outcome),
            };
            if !impacted || event.outcome != PopulateOutcome::Unchanged {
                print_event(&event);
            }
        }
    }

    Ok(())
}

fn resolve_legacy_var(
    spec: &crate::config::legacy::LegacyVarSpec,
    resolved: &HashMap<String, String>,
) -> Result<Option<String>> {
    use crate::config::legacy::LegacyVarSpec;

    match spec {
        LegacyVarSpec::Inline(v) => Ok(Some(v.clone())),
        LegacyVarSpec::Structured(def) => {
            if let Some(env_var) = &def.env {
                if let Ok(val) = std::env::var(env_var) {
                    if !val.is_empty() {
                        return Ok(Some(val));
                    }
                }
            }
            if let Some(gen) = &def.generate {
                use crate::engine::generate;
                use crate::config::v1::AutoKind;
                let kind = match gen.as_str() {
                    "password" => AutoKind::Password,
                    "hex" => AutoKind::Hex,
                    "django" => AutoKind::Django,
                    _ => AutoKind::Password,
                };
                return Ok(Some(generate::generate_value(&kind, 32)?));
            }
            if let Some(inherit) = &def.inherit {
                if let Some(val) = resolved.get(inherit.as_str()) {
                    return Ok(Some(val.clone()));
                }
            }
            if let Some(default) = &def.default {
                return Ok(Some(default.clone()));
            }
            if def.optional {
                return Ok(None);
            }
            Ok(None)
        }
    }
}

fn outcome_to_populate(o: SetSecretOutcome) -> PopulateOutcome {
    match o {
        SetSecretOutcome::Created | SetSecretOutcome::WouldCreate => PopulateOutcome::Created,
        SetSecretOutcome::Updated | SetSecretOutcome::WouldUpdate => PopulateOutcome::Updated,
        SetSecretOutcome::Unchanged => PopulateOutcome::Unchanged,
    }
}
