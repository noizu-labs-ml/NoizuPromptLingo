//! Enumerate locally available sandbox images by their [`APPS_LABEL`].

use super::slug::{AppSet, APPS_LABEL};
use crate::docker;
use crate::error::Result;

/// A local image that carries the agent-sandbox apps label.
#[derive(Debug, Clone)]
pub struct SandboxImage {
    pub reference: String,
    pub apps: Vec<String>,
    pub app_set: AppSet,
}

/// List local images tagged with the apps label. Returns an empty vec (not an
/// error) when docker is unavailable, so callers can still build from scratch.
pub fn list_sandbox_images() -> Result<Vec<SandboxImage>> {
    if !docker::is_available() {
        return Ok(Vec::new());
    }

    // References of images carrying our label.
    let refs = docker::run_capture(&[
        "images",
        "--filter",
        &format!("label={APPS_LABEL}"),
        "--format",
        "{{.Repository}}:{{.Tag}}",
    ])?;

    let mut images = Vec::new();
    for line in refs.lines() {
        let reference = line.trim();
        if reference.is_empty() || reference.contains("<none>") {
            continue;
        }
        let label = docker::run_capture(&[
            "inspect",
            "--format",
            &format!("{{{{ index .Config.Labels \"{APPS_LABEL}\" }}}}"),
            reference,
        ])
        .unwrap_or_default();
        let label = label.trim();
        if label.is_empty() {
            continue;
        }
        let app_set = AppSet::from_label(label);
        images.push(SandboxImage {
            reference: reference.to_string(),
            apps: app_set.slugs().map(|s| s.to_string()).collect(),
            app_set,
        });
    }
    Ok(images)
}
