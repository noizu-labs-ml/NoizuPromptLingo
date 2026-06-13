//! Project discovery and config loading.

mod merge;
mod schema;

pub use merge::{config_value, materialize, parent_config_values};
pub use schema::*;

use crate::error::{Result, SandboxError};
use crate::paths;
use anyhow::Context;
use serde_yaml::Value;
use std::path::{Path, PathBuf};
use std::process::Command;

/// A discovered project: the git repo root the user invoked us from.
#[derive(Debug, Clone)]
pub struct Project {
    pub root: PathBuf,
}

impl Project {
    /// Discover the enclosing git repository from the current directory.
    pub fn discover() -> Result<Self> {
        let out = Command::new("git")
            .args(["rev-parse", "--show-toplevel"])
            .output()
            .context("failed to invoke git")?;
        if !out.status.success() {
            return Err(SandboxError::NotAGitRepo.into());
        }
        let root = String::from_utf8_lossy(&out.stdout).trim().to_string();
        Ok(Self {
            root: PathBuf::from(root),
        })
    }

    /// Path to the `.agent-sandbox` directory at the project root.
    pub fn sandbox_dir(&self) -> PathBuf {
        self.root.join(paths::PROJECT_DIR)
    }

    /// Path to the `.agent-sandbox/config` file (may not exist).
    pub fn config_path(&self) -> PathBuf {
        self.sandbox_dir().join(paths::CONFIG_FILE)
    }

    /// Whether a project config exists.
    pub fn has_config(&self) -> bool {
        self.config_path().exists()
    }

    /// Load the project config, falling back to defaults if none exists.
    pub fn load_config(&self) -> Result<SandboxConfig> {
        let path = self.config_path();
        if !path.exists() {
            return Ok(SandboxConfig::default());
        }
        load_config_file(&path)
    }

    /// Effective config = parent configs (far→near) layered, then the project's
    /// own config on top. Used by the launch path so parent repos can provide
    /// shared defaults.
    pub fn load_effective(&self) -> Result<SandboxConfig> {
        let mut layers = parent_config_values(self)?;
        if self.has_config() {
            layers.push(config_value(&self.config_path())?);
        }
        materialize(&layers)
    }
}

/// Load a template's raw YAML value (for use as a merge layer).
pub fn template_value(name: &str) -> Result<Value> {
    let path = paths::templates_dir().join(name).join("config.yaml");
    config_value(&path)
}

/// Parse a config file from disk.
pub fn load_config_file(path: &Path) -> Result<SandboxConfig> {
    let raw = std::fs::read_to_string(path)
        .with_context(|| format!("reading config {}", path.display()))?;
    let cfg: SandboxConfig = serde_yaml::from_str(&raw)
        .with_context(|| format!("parsing config {}", path.display()))?;
    Ok(cfg)
}

/// List installed template names under `~/.config/agent-sandbox/templates`.
pub fn list_templates() -> Result<Vec<String>> {
    let dir = paths::templates_dir();
    if !dir.exists() {
        return Ok(Vec::new());
    }
    let mut names = Vec::new();
    for entry in std::fs::read_dir(&dir)
        .with_context(|| format!("listing templates {}", dir.display()))?
    {
        let entry = entry?;
        if entry.file_type()?.is_dir() {
            if let Some(name) = entry.file_name().to_str() {
                names.push(name.to_string());
            }
        }
    }
    names.sort();
    Ok(names)
}

/// Save the current project's config as a named template.
pub fn save_template(project: &Project, name: &str) -> Result<PathBuf> {
    let cfg = project.load_config()?;
    let dir = paths::templates_dir().join(name);
    std::fs::create_dir_all(&dir)
        .with_context(|| format!("creating template dir {}", dir.display()))?;
    let out = dir.join("config.yaml");
    let yaml = serde_yaml::to_string(&cfg).context("serializing config")?;
    std::fs::write(&out, yaml).with_context(|| format!("writing {}", out.display()))?;
    Ok(out)
}
