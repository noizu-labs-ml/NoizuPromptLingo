//! Append-only audit log for secret reveals.
//!
//! Every time a secret is decrypted for human/consumer output (`dc get --reveal`,
//! `--clippy`, `dc bat --reveal`, `compare`, `push`, …) a structured JSONL record
//! is appended. The log records *what* was revealed (subject, path, tier, method)
//! and *who/when* — never the plaintext value.
//!
//! Location: `audit_log` from settings.yaml if set, else
//! `~/.local/state/direnv-config/audit.log` (mode 0600). Write failures warn on
//! stderr but never block the operation (infisical-populate must not be broken by
//! an unwritable log).

use anyhow::Result;
use std::io::Write;
use std::path::PathBuf;

fn audit_path() -> PathBuf {
    if let Ok(s) = crate::settings::load() {
        if let Some(p) = s.audit_log {
            return p;
        }
    }
    crate::store::layout::state_dir().join("audit.log")
}

fn current_user() -> String {
    std::env::var("USER")
        .or_else(|_| std::env::var("LOGNAME"))
        .unwrap_or_else(|_| "unknown".to_string())
}

/// Record a secret reveal. Best-effort: a failure warns but does not error.
pub fn record(subject: &str, path: &str, tier: u8, method: &str) {
    if let Err(e) = try_record(subject, path, tier, method) {
        eprintln!("dc: warning: failed to write audit log: {e}");
    }
}

fn try_record(subject: &str, path: &str, tier: u8, method: &str) -> Result<()> {
    let store_src = crate::store::find_current_store()
        .ok()
        .and_then(|s| crate::store::meta::read_meta(&s).ok())
        .map(|m| m.source.to_string_lossy().into_owned());

    let euid = unsafe { libc::geteuid() };

    let entry = serde_json::json!({
        "ts": chrono::Utc::now().to_rfc3339(),
        "user": current_user(),
        "euid": euid,
        "subject": subject,
        "path": path,
        "tier": tier,
        "method": method,
        "store": store_src,
    });

    let file = audit_path();
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let mut f = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&file)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let _ = std::fs::set_permissions(&file, std::fs::Permissions::from_mode(0o600));
    }
    writeln!(f, "{}", serde_json::to_string(&entry)?)?;
    Ok(())
}
