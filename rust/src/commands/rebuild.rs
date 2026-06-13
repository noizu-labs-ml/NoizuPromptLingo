use anyhow::Result;
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::path::Path;

use crate::cli::{RebuildArgs, RebuildPhase};
use crate::config::{SecretsConfig, discover_config};

use super::creds;

pub async fn run(args: RebuildArgs) -> Result<()> {
    let env = args.env_flags.resolve();
    let config_path = discover_config(args.config.config.as_deref())?;
    let out_dir = std::path::PathBuf::from(&args.output_dir);

    std::fs::create_dir_all(&out_dir)?;

    let config = SecretsConfig::load(&config_path)?;

    match args.phase {
        RebuildPhase::Scan => {
            run_scan(&config, &env, args.show_secrets, &out_dir).await?;
        }
        RebuildPhase::Analyze => {
            run_analyze(&out_dir)?;
        }
        RebuildPhase::Generate => {
            if !args.show_secrets {
                anyhow::bail!("generate phase requires --show-secrets");
            }
            run_generate(&out_dir, args.dry_run)?;
        }
        RebuildPhase::All => {
            run_scan(&config, &env, args.show_secrets, &out_dir).await?;
            run_analyze(&out_dir)?;
            if args.show_secrets {
                run_generate(&out_dir, args.dry_run)?;
            } else {
                eprintln!("Skipping generate phase (re-run with --show-secrets to generate output files)");
            }
        }
    }

    Ok(())
}

// ── Phase 1: Scan ─────────────────────────────────────────────────────────────

#[derive(serde::Serialize, serde::Deserialize, Debug, Clone)]
struct InventoryItem {
    path: String,
    key: String,
    value_hash: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    value: Option<String>,
}

async fn run_scan(
    config: &SecretsConfig,
    env: &str,
    show_secrets: bool,
    out_dir: &Path,
) -> Result<()> {
    eprintln!("Phase 1: Scan");

    let client = creds::build_client(env).await?;

    let paths = match config {
        SecretsConfig::V1(cfg) => cfg.all_paths().iter().map(|s| s.to_string()).collect::<Vec<_>>(),
        SecretsConfig::Legacy(cfg) => cfg.folders.clone(),
    };

    let mut inventory: Vec<InventoryItem> = Vec::new();

    for path in &paths {
        eprintln!("  Scanning {path}");
        let secrets = match client.list_secrets(path).await {
            Ok(s) => s,
            Err(e) => {
                eprintln!("  WARN: {path}: {e}");
                continue;
            }
        };

        for s in secrets {
            let hash = hex::encode(Sha256::digest(s.value.as_bytes()));
            inventory.push(InventoryItem {
                path: path.clone(),
                key: s.key,
                value_hash: hash,
                value: if show_secrets { Some(s.value) } else { None },
            });
        }
    }

    let inventory_path = out_dir.join("inventory.json");
    std::fs::write(&inventory_path, serde_json::to_string_pretty(&inventory)?)?;
    eprintln!("  Wrote {}", inventory_path.display());
    eprintln!("  {} secrets scanned", inventory.len());

    Ok(())
}

// ── Phase 2: Analyze ─────────────────────────────────────────────────────────

#[derive(serde::Serialize, serde::Deserialize, Debug)]
struct DuplicateGroup {
    hash: String,
    count: usize,
    classification: String,
    items: Vec<InventoryItem>,
}

fn run_analyze(out_dir: &Path) -> Result<()> {
    eprintln!("Phase 2: Analyze");

    let inventory_path = out_dir.join("inventory.json");
    let data = std::fs::read_to_string(&inventory_path)
        .map_err(|_| anyhow::anyhow!("inventory.json not found — run scan phase first"))?;
    let inventory: Vec<InventoryItem> = serde_json::from_str(&data)?;

    // Group by value_hash
    let mut by_hash: HashMap<String, Vec<InventoryItem>> = HashMap::new();
    for item in inventory {
        by_hash.entry(item.value_hash.clone()).or_default().push(item);
    }

    let mut groups: Vec<DuplicateGroup> = by_hash
        .into_iter()
        .filter(|(_, items)| items.len() > 1)
        .map(|(hash, items)| {
            let count = items.len();
            let classification = if count >= 3 {
                "shared-credential"
            } else {
                "review"
            }
            .to_owned();
            DuplicateGroup { hash, count, classification, items }
        })
        .collect();

    groups.sort_by(|a, b| b.count.cmp(&a.count));

    let dups_path = out_dir.join("duplicates.json");
    std::fs::write(&dups_path, serde_json::to_string_pretty(&groups)?)?;
    eprintln!("  Wrote {}", dups_path.display());

    // Write human-readable report
    let mut report = String::new();
    report.push_str("# Rebuild Analysis Report\n\n");
    report.push_str(&format!("## Duplicate Groups ({})\n\n", groups.len()));
    for g in &groups {
        report.push_str(&format!(
            "### {} ({}, hash: {}...)\n\n",
            g.classification,
            g.count,
            &g.hash[..8]
        ));
        for item in &g.items {
            report.push_str(&format!("- `{}` at `{}`\n", item.key, item.path));
        }
        report.push('\n');
    }

    let report_path = out_dir.join("report.txt");
    std::fs::write(&report_path, &report)?;
    eprintln!("  Wrote {}", report_path.display());
    eprintln!("  {} duplicate groups found", groups.len());

    Ok(())
}

// ── Phase 3: Generate ────────────────────────────────────────────────────────

fn run_generate(out_dir: &Path, dry_run: bool) -> Result<()> {
    eprintln!("Phase 3: Generate");

    let inventory_path = out_dir.join("inventory.json");
    let data = std::fs::read_to_string(&inventory_path)
        .map_err(|_| anyhow::anyhow!("inventory.json not found — run scan phase first"))?;
    let inventory: Vec<InventoryItem> = serde_json::from_str(&data)?;

    // Generate new .envrc.dc sections (one YAML block per path)
    let mut by_path: HashMap<String, Vec<&InventoryItem>> = HashMap::new();
    for item in &inventory {
        by_path.entry(item.path.clone()).or_default().push(item);
    }

    let mut envrc_new = String::new();
    envrc_new.push_str("# Generated by infisical rebuild — review before applying\n\n");

    for (path, items) in &by_path {
        let block_name = path.trim_matches('/').replace('/', "_");
        envrc_new.push_str(&format!("# Path: {path}\n"));
        envrc_new.push_str(&format!("dc_yaml --no-bump secrets --layer {block_name} << 'EOF'\n"));
        for item in items {
            if let Some(val) = &item.value {
                envrc_new.push_str(&format!("  {}: \"{}\"\n", item.key.to_lowercase(), val));
            } else {
                envrc_new.push_str(&format!("  {}: \"\"\n", item.key.to_lowercase()));
            }
        }
        envrc_new.push_str("EOF\n\n");
    }

    let envrc_out = out_dir.join(".envrc.new.dc");
    if dry_run {
        eprintln!("  [dry-run] Would write {}", envrc_out.display());
        print!("{}", envrc_new);
    } else {
        std::fs::write(&envrc_out, &envrc_new)?;
        eprintln!("  Wrote {}", envrc_out.display());
    }

    Ok(())
}
