use anyhow::Result;
use std::collections::HashMap;

use crate::cli::BootstrapArgs;

pub fn run(args: BootstrapArgs) -> Result<()> {
    let namespace = args.namespace.as_deref().unwrap_or("infisical");

    // Collect required env vars
    let pg_password = require_env("INFISICAL_POSTGRES_PASSWORD")?;
    let enc_key = require_env("INFISICAL_ENCRYPTION_KEY")?;
    let auth_secret = require_env("INFISICAL_AUTH_SECRET")?;
    let redis_password = std::env::var("INFISICAL_REDIS_PASSWORD")
        .or_else(|_| std::env::var("INFISCIAL_REDIS_PASSWORD")) // legacy typo
        .unwrap_or_default();

    let optional: HashMap<&str, Option<String>> = [
        ("INFISICAL_POSTGRES_ADMIN_PASSWORD", std::env::var("INFISICAL_POSTGRES_ADMIN_PASSWORD").ok()),
        ("SENDGRID_API_KEY", std::env::var("SENDGRID_API_KEY").ok()),
        ("SMTP_FROM", std::env::var("SMTP_FROM").ok()),
        ("GOOGLE_CLIENT_ID", std::env::var("GOOGLE_CLIENT_ID").ok()),
        ("GOOGLE_CLIENT_SECRET", std::env::var("GOOGLE_CLIENT_SECRET").ok()),
    ]
    .into();

    if !args.tls_only {
        create_app_secret(namespace, &pg_password, &enc_key, &auth_secret, &redis_password, &optional, args.dry_run)?;
    }

    // TLS secret
    let tls_crt = std::env::var("TLS_CRT").ok();
    let tls_key = std::env::var("TLS_KEY").ok();
    if args.tls_only || (tls_crt.is_some() && tls_key.is_some()) {
        if let (Some(crt), Some(key)) = (tls_crt, tls_key) {
            create_tls_secret(namespace, &crt, &key, args.dry_run)?;
        }
    }

    if !args.dry_run {
        println!("\nBootstrap complete. To deploy Infisical:");
        println!("  helm-upgrade --include infisical");
    }

    Ok(())
}

fn create_app_secret(
    namespace: &str,
    pg_password: &str,
    enc_key: &str,
    auth_secret: &str,
    redis_password: &str,
    optional: &std::collections::HashMap<&str, Option<String>>,
    dry_run: bool,
) -> Result<()> {
    let db_uri = format!(
        "postgresql://infisical:{}@postgres:5432/infisical",
        pg_password
    );
    let redis_url = format!("redis://:{}@redis:6379/0", redis_password);

    let mut args = vec![
        "create".to_owned(),
        "secret".to_owned(),
        "generic".to_owned(),
        "infisical-bootstrap".to_owned(),
        format!("--namespace={}", namespace),
        "--save-config".to_owned(),
        "--dry-run=client".to_owned(), // always validate first
        format!("--from-literal=DB_CONNECTION_URI={}", db_uri),
        format!("--from-literal=ENCRYPTION_KEY={}", enc_key),
        format!("--from-literal=AUTH_SECRET={}", auth_secret),
        format!("--from-literal=REDIS_URL={}", redis_url),
    ];

    for (env_var, val) in optional {
        if let Some(v) = val {
            args.push(format!("--from-literal={}={}", env_var, v));
        }
    }

    if dry_run {
        println!("[dry-run] kubectl {}", args.join(" "));
    } else {
        // Delete existing first (ignore errors)
        let _ = std::process::Command::new("kubectl")
            .args(["delete", "secret", "infisical-bootstrap", &format!("-n={}", namespace), "--ignore-not-found=true"])
            .status();

        // Remove --dry-run=client for real execution
        args.retain(|a| a != "--dry-run=client");
        kubectl_run(&args)?;
        println!("✓ Created app secret 'infisical-bootstrap'");
    }

    Ok(())
}

fn create_tls_secret(namespace: &str, tls_crt_b64: &str, tls_key_b64: &str, dry_run: bool) -> Result<()> {
    use base64::{engine::general_purpose::STANDARD, Engine as _};

    let crt = STANDARD.decode(tls_crt_b64.trim())?;
    let key = STANDARD.decode(tls_key_b64.trim())?;

    // Write to tmpdir
    let tmp = std::env::temp_dir();
    let crt_path = tmp.join("tls.crt");
    let key_path = tmp.join("tls.key");
    std::fs::write(&crt_path, crt)?;
    std::fs::write(&key_path, key)?;

    let kubectl_args = vec![
        "create".to_owned(),
        "secret".to_owned(),
        "tls".to_owned(),
        "infisical-tls".to_owned(),
        format!("--namespace={}", namespace),
        format!("--cert={}", crt_path.display()),
        format!("--key={}", key_path.display()),
    ];

    if dry_run {
        println!("[dry-run] kubectl {}", kubectl_args.join(" "));
    } else {
        let _ = std::process::Command::new("kubectl")
            .args(["delete", "secret", "infisical-tls", &format!("-n={}", namespace), "--ignore-not-found=true"])
            .status();
        kubectl_run(&kubectl_args)?;
        println!("✓ Created TLS secret 'infisical-tls'");
    }

    // Clean up tmp files
    let _ = std::fs::remove_file(crt_path);
    let _ = std::fs::remove_file(key_path);

    Ok(())
}

fn kubectl_run(args: &[String]) -> Result<()> {
    let status = std::process::Command::new("kubectl")
        .args(args)
        .status()?;
    if !status.success() {
        anyhow::bail!("kubectl exited with status {}", status);
    }
    Ok(())
}

fn require_env(name: &str) -> Result<String> {
    std::env::var(name).map_err(|_| {
        anyhow::anyhow!("Required env var not set: {}", name)
    })
}
