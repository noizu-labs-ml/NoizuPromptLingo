use anyhow::Result;
use std::process;

use crate::cli::{AuditArgs, AuditFormat};
use crate::config::{SecretsConfig, discover_config};
use crate::engine::{verify_all, VerifyStatus, VerifySummary};

use super::creds;

pub async fn run(args: AuditArgs) -> Result<()> {
    let env = args.env_flags.resolve();
    let config_path = discover_config(args.config.config.as_deref())?;

    eprintln!("Config: {}", config_path.display());
    eprintln!("Environment: {env}");

    let config = SecretsConfig::load(&config_path)?;
    let client = creds::build_client(&env).await?;

    let sections = match &config {
        SecretsConfig::V1(cfg) => cfg.sections.clone(),
        SecretsConfig::Legacy(_) => {
            anyhow::bail!("audit: legacy config format not supported");
        }
    };

    let results = verify_all(&client, &sections, args.show_diff, false).await?;
    let summary = VerifySummary::from_results(&results);

    let output = match args.format {
        AuditFormat::Json => serde_json::to_string_pretty(&serde_json::json!({
            "environment": env,
            "config_file": config_path.display().to_string(),
            "summary": summary,
            "results": results
        }))?,
        AuditFormat::Markdown => render_markdown(&results, &summary, &env, &config_path.display().to_string()),
    };

    if let Some(export_path) = &args.export {
        std::fs::write(export_path, &output)?;
        eprintln!("Report written to {export_path}");
    } else {
        println!("{output}");
    }

    if !summary.all_ok() {
        process::exit(1);
    }
    Ok(())
}

fn render_markdown(
    results: &[crate::engine::VerifyResult],
    summary: &VerifySummary,
    env: &str,
    config_file: &str,
) -> String {
    let mut out = String::new();

    out.push_str("# Infisical Secrets Audit\n\n");
    out.push_str(&format!("**Environment:** `{env}`  \n"));
    out.push_str(&format!("**Config:** `{config_file}`\n\n"));

    out.push_str("## Summary\n\n");
    out.push_str("| Status | Count |\n|--------|-------|\n");
    out.push_str(&format!("| ✓ ok | {} |\n", summary.ok));
    out.push_str(&format!("| ≠ mismatch | {} |\n", summary.mismatch));
    out.push_str(&format!("| dc? missing_dc | {} |\n", summary.missing_dc));
    out.push_str(&format!("| inf? missing_infisical | {} |\n", summary.missing_infisical));
    out.push_str(&format!("| ✗ missing_all | {} |\n", summary.missing_all));
    out.push_str(&format!("| **Total** | **{}** |\n\n", summary.total));

    if summary.all_ok() {
        out.push_str("✅ All secrets are in sync.\n");
        return out;
    }

    // Mismatches
    let mismatches: Vec<_> = results
        .iter()
        .filter(|r| r.status == VerifyStatus::Mismatch)
        .collect();
    if !mismatches.is_empty() {
        out.push_str("## Mismatches\n\n");
        out.push_str("| Name | Section | Path |\n|------|---------|------|\n");
        for r in &mismatches {
            out.push_str(&format!("| `{}` | `{}` | `{}` |\n", r.name, r.section_id, r.path));
        }
        out.push('\n');
    }

    // Missing
    let missing: Vec<_> = results
        .iter()
        .filter(|r| {
            matches!(
                r.status,
                VerifyStatus::MissingDc
                    | VerifyStatus::MissingInfisical
                    | VerifyStatus::MissingAll
            )
        })
        .collect();
    if !missing.is_empty() {
        out.push_str("## Missing\n\n");
        out.push_str("| Name | Section | Status |\n|------|---------|--------|\n");
        for r in &missing {
            out.push_str(&format!(
                "| `{}` | `{}` | {} |\n",
                r.name,
                r.section_id,
                r.status.label()
            ));
        }
        out.push('\n');
    }

    out
}
