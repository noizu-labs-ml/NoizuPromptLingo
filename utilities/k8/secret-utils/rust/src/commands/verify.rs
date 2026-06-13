use anyhow::Result;
use std::process;

use crate::cli::VerifyArgs;
use crate::config::{SecretsConfig, discover_config};
use crate::engine::{verify_all, verify_section, verify_secret, VerifySummary};
use crate::tui::{self, verify_view};

use super::creds;

pub async fn run(args: VerifyArgs) -> Result<()> {
    let env = args.env_flags.resolve();
    let config_path = discover_config(args.config.config.as_deref())?;

    eprintln!("Config: {}", config_path.display());
    eprintln!("Environment: {env}");

    let config = SecretsConfig::load(&config_path)?;
    let client = creds::build_client(&env).await?;

    let sections = match &config {
        SecretsConfig::V1(cfg) => cfg.sections.clone(),
        SecretsConfig::Legacy(_) => {
            eprintln!("verify: legacy config format not fully supported for verification");
            return Ok(());
        }
    };

    let results = if let Some(secret_name) = &args.secret {
        // Find section + spec for this one secret
        let mut found = None;
        'outer: for section in &sections {
            for (name, spec) in &section.secrets {
                if name == secret_name {
                    let r = verify_secret(&client, section, name, spec, args.show_values).await?;
                    found = Some(vec![r]);
                    break 'outer;
                }
            }
        }
        found.unwrap_or_else(|| {
            eprintln!("Secret '{secret_name}' not found in config");
            vec![]
        })
    } else if let Some(section_id) = &args.section {
        let section = sections.iter().find(|s| s.id == *section_id).ok_or_else(|| {
            anyhow::anyhow!("Section '{}' not found in config", section_id)
        })?;
        verify_section(&client, section, args.show_values, args.fail_fast).await?
    } else {
        verify_all(&client, &sections, args.show_values, args.fail_fast).await?
    };

    // Optional JSON report export
    if let Some(report_file) = &args.report_file {
        let summary = VerifySummary::from_results(&results);
        let report = serde_json::json!({
            "generated_at": chrono_now(),
            "environment": env,
            "config_file": config_path.display().to_string(),
            "project_id": client.cfg.project_id,
            "summary": summary,
            "results": results
        });
        std::fs::write(report_file, serde_json::to_string_pretty(&report)?)?;
        eprintln!("Report written to {report_file}");
    }

    let summary = VerifySummary::from_results(&results);

    if !args.no_tui && tui::is_tty() {
        verify_view::VerifyView::new(results, args.show_values).run()?;
    } else {
        verify_view::print_results_plain(&results, args.show_values);
    }

    if !summary.all_ok() {
        process::exit(1);
    }
    Ok(())
}

fn chrono_now() -> String {
    // Use process start time approximation — no chrono dep
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    format!("{}", secs)
}
