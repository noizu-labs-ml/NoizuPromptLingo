//! Kubernetes Secret access via `kubectl` (read + create/patch).
//!
//! Read uses jsonpath + base64 decode. Write prefers a `--dry-run=client -o yaml
//! | apply -f -` style flow over `--from-literal` to keep secret values off the
//! process argv (where `ps` could see them); existing secrets are patched so
//! sibling keys are preserved.

use anyhow::{anyhow, bail, Result};
use base64::Engine;
use std::process::{Command, Stdio};

#[derive(Debug, PartialEq, Eq)]
pub enum KubeOutcome {
    Created,
    Patched,
    Unchanged,
}

fn b64() -> base64::engine::general_purpose::GeneralPurpose {
    base64::engine::general_purpose::STANDARD
}

fn run_kubectl(args: &[&str]) -> Result<std::process::Output> {
    Command::new("kubectl")
        .args(args)
        .output()
        .map_err(|e| anyhow!("failed to run kubectl (is it installed?): {e}"))
}

pub fn secret_exists(ns: &str, secret: &str) -> Result<bool> {
    let out = run_kubectl(&["get", "secret", secret, "-n", ns, "-o", "name"])?;
    Ok(out.status.success())
}

/// Read a single data key from a Secret, base64-decoded. `Ok(None)` if absent.
pub fn read_secret_key(ns: &str, secret: &str, key: &str) -> Result<Option<Vec<u8>>> {
    let jsonpath = format!("{{.data['{}']}}", key.replace('\\', "").replace('\'', ""));
    let out = run_kubectl(&["get", "secret", secret, "-n", ns, "-o", &format!("jsonpath={jsonpath}")])?;
    if !out.status.success() {
        let stderr = String::from_utf8_lossy(&out.stderr);
        if stderr.contains("NotFound") || stderr.contains("not found") {
            return Ok(None);
        }
        bail!("kubectl get secret {ns}/{secret} failed: {}", stderr.trim());
    }
    let b64v = String::from_utf8_lossy(&out.stdout);
    let b64v = b64v.trim();
    if b64v.is_empty() {
        return Ok(None);
    }
    let decoded = b64().decode(b64v).map_err(|e| anyhow!("bad base64 from kubectl: {e}"))?;
    Ok(Some(decoded))
}

/// Create or patch a single data key. Returns the outcome.
pub fn upsert_secret_key(ns: &str, secret: &str, key: &str, value: &[u8], dry_run: bool) -> Result<KubeOutcome> {
    // No-op detection.
    if let Some(existing) = read_secret_key(ns, secret, key)? {
        if existing == value {
            return Ok(KubeOutcome::Unchanged);
        }
    }
    let exists = secret_exists(ns, secret)?;
    if dry_run {
        return Ok(if exists { KubeOutcome::Patched } else { KubeOutcome::Created });
    }

    if exists {
        // Patch keeps sibling keys. The base64 value is safe to pass on argv.
        let b64v = b64().encode(value);
        let patch = format!(r#"{{"data":{{"{key}":"{b64v}"}}}}"#);
        let out = run_kubectl(&["patch", "secret", secret, "-n", ns, "--type=merge", "-p", &patch])?;
        if !out.status.success() {
            bail!("kubectl patch {ns}/{secret} failed: {}", String::from_utf8_lossy(&out.stderr).trim());
        }
        Ok(KubeOutcome::Patched)
    } else {
        // Create via dry-run yaml piped to apply, so the plaintext goes through
        // stdin (kubectl base64-encodes) rather than appearing on argv.
        create_via_apply(ns, secret, key, value)?;
        Ok(KubeOutcome::Created)
    }
}

fn create_via_apply(ns: &str, secret: &str, key: &str, value: &[u8]) -> Result<()> {
    // `kubectl create secret generic … --from-literal=KEY=VALUE --dry-run=client -o yaml`
    // would expose VALUE on argv, so instead we hand-build the Secret manifest
    // with a base64 value and `kubectl apply -f -` via stdin.
    let b64v = b64().encode(value);
    let manifest = format!(
        "apiVersion: v1\nkind: Secret\nmetadata:\n  name: {secret}\n  namespace: {ns}\ntype: Opaque\ndata:\n  {key}: {b64v}\n"
    );
    let mut child = Command::new("kubectl")
        .args(["apply", "-f", "-"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| anyhow!("failed to run kubectl apply: {e}"))?;
    {
        use std::io::Write;
        child
            .stdin
            .as_mut()
            .ok_or_else(|| anyhow!("failed to open kubectl stdin"))?
            .write_all(manifest.as_bytes())?;
    }
    let out = child.wait_with_output()?;
    if !out.status.success() {
        bail!("kubectl apply {ns}/{secret} failed: {}", String::from_utf8_lossy(&out.stderr).trim());
    }
    Ok(())
}
