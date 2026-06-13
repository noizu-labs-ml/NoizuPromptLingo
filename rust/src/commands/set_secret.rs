use anyhow::Result;
use std::io::{self, Write};

use crate::api::SetSecretOutcome;
use crate::cli::SetArgs;
use crate::config::{SecretsConfig, discover_config};
use crate::dc;
use crate::engine::generate;

use super::creds;

pub async fn run(args: SetArgs) -> Result<()> {
    let env = args.env_flags.resolve();
    let config_path = discover_config(args.config.config.as_deref())?;

    let config = SecretsConfig::load(&config_path)?;

    let (section, spec) = match &config {
        SecretsConfig::V1(cfg) => {
            let mut found = None;
            'outer: for section in &cfg.sections {
                for (name, spec) in &section.secrets {
                    if name == &args.name {
                        found = Some((section.clone(), spec.clone()));
                        break 'outer;
                    }
                }
            }
            found.ok_or_else(|| {
                anyhow::anyhow!("Secret '{}' not found in config", args.name)
            })?
        }
        SecretsConfig::Legacy(_) => {
            anyhow::bail!("set: legacy config format not supported");
        }
    };

    // Determine the new value
    let new_value = if let Some(v) = args.value {
        v
    } else if args.generate {
        let auto = spec.auto.as_ref().ok_or_else(|| {
            anyhow::anyhow!("--generate requested but no 'auto' spec in config for '{}'", args.name)
        })?;
        generate::generate_value(&auto.kind, auto.length)?
    } else {
        // Interactive hidden prompt
        prompt_secret(&format!("New value for '{}': ", args.name))?
    };

    // Get current dc value for comparison
    let current_dc = spec.dc.as_ref()
        .and_then(|r| dc::dc_get_optional(&r.scope, &r.path));

    if let Some(ref cur) = current_dc {
        if cur == &new_value {
            println!("Value unchanged — skipping.");
            return Ok(());
        }
    }

    // Show summary and confirm
    println!("\nSecret: {}", args.name);
    println!("Section: {} ({})", section.title, section.id);
    println!("Path: {}", section.path);
    if let Some(ref dc_ref) = spec.dc {
        println!("dc: {} {}", dc_ref.scope, dc_ref.path);
    }
    println!("Current: {}", current_dc.as_deref().unwrap_or("(not set)"));
    println!("New:     {}", "*".repeat(new_value.len().min(8)));

    if args.dry_run {
        println!("\n[dry-run] Would update dc and Infisical.");
        return Ok(());
    }

    if !confirm("[Y/n] Apply changes? ")? {
        println!("Aborted.");
        return Ok(());
    }

    // Step 1: update dc
    if let Some(ref dc_ref) = spec.dc {
        dc::dc_set(&dc_ref.scope, &dc_ref.path, &new_value)?;
        println!("✓ dc set {} {}", dc_ref.scope, dc_ref.path);
    }

    // Step 2: update Infisical
    let client = creds::build_client(&env).await?;
    let outcome = client.set_secret(&section.path, &args.name, &new_value, false).await?;

    match outcome {
        SetSecretOutcome::Created => println!("✓ Infisical: created"),
        SetSecretOutcome::Updated => println!("✓ Infisical: updated"),
        SetSecretOutcome::Unchanged => println!("= Infisical: unchanged"),
        _ => {}
    }

    // --cascade: identify dependents
    if args.cascade {
        find_cascade_dependents(&config, &args.name);
    }

    Ok(())
}

fn prompt_secret(prompt: &str) -> Result<String> {
    print!("{}", prompt);
    io::stdout().flush()?;
    let value = rpassword::read_password()?;
    Ok(value)
}

fn confirm(prompt: &str) -> Result<bool> {
    print!("{}", prompt);
    io::stdout().flush()?;
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    let trimmed = input.trim().to_lowercase();
    Ok(trimmed.is_empty() || trimmed == "y" || trimmed == "yes")
}

fn find_cascade_dependents(config: &SecretsConfig, target_name: &str) {
    let sections = match config {
        SecretsConfig::V1(cfg) => &cfg.sections,
        _ => return,
    };

    let mut found = Vec::new();
    for section in sections {
        for (name, spec) in &section.secrets {
            if name == target_name {
                continue;
            }
            // Check for ref
            if spec.ref_.as_deref() == Some(target_name) {
                found.push(format!("  ref: {} ({})", name, section.id));
            }
            // Check template for {{TARGET_NAME}}
            if let Some(tmpl) = &spec.template {
                if tmpl.contains(&format!("{{{{{}}}}}", target_name)) {
                    found.push(format!("  template: {} ({})", name, section.id));
                }
            }
        }
    }

    if !found.is_empty() {
        println!("\nCascade dependents (may also need updating):");
        for dep in found {
            println!("{dep}");
        }
    } else {
        println!("\nNo cascade dependents found.");
    }
}
