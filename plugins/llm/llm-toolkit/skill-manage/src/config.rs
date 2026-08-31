use crate::kinds::{Kind, Provider};
use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AppConfig {
    #[serde(default = "default_version")]
    pub version: u32,
    #[serde(default)]
    pub sources: SourcesConfig,
    #[serde(default)]
    pub providers: BTreeMap<String, ProviderDirs>,
    #[serde(default)]
    pub catalog: Option<PathBuf>,
    #[serde(default)]
    pub defaults: DefaultsConfig,
}

fn default_version() -> u32 {
    1
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SourcesConfig {
    #[serde(default)]
    pub skills: Vec<SourceRoot>,
    #[serde(default)]
    pub agents: Vec<SourceRoot>,
    #[serde(default)]
    pub commands: Vec<SourceRoot>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceRoot {
    pub path: PathBuf,
    #[serde(default = "default_priority")]
    pub priority: i32,
}

fn default_priority() -> i32 {
    100
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ProviderDirs {
    pub skills_dir: Option<PathBuf>,
    pub agents_dir: Option<PathBuf>,
    pub commands_dir: Option<PathBuf>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DefaultsConfig {
    #[serde(default = "default_provider_str")]
    pub provider: String,
    #[serde(default)]
    pub replace: bool,
}

impl Default for DefaultsConfig {
    fn default() -> Self {
        Self {
            provider: default_provider_str(),
            replace: false,
        }
    }
}

fn default_provider_str() -> String {
    "all".into()
}

impl AppConfig {
    // ⟦𓂾𓏳𓍜𓊖⟧ default_config_path :: auto-generated pointer for public function default_config_path
    pub fn default_config_path() -> PathBuf {
        if let Ok(p) = env::var("SKILL_MANAGE_CONFIG") {
            return expand_path(PathBuf::from(p));
        }
        dirs::config_dir()
            .unwrap_or_else(|| PathBuf::from(".").join(".config"))
            .join("skill-manage")
            .join("config.yaml")
    }

    // ⟦𓍊𓉹𓍰𓀐⟧ load :: auto-generated pointer for public function load
    pub fn load(path: Option<&Path>) -> Result<Self> {
        let path = path
            .map(Path::to_path_buf)
            .unwrap_or_else(Self::default_config_path);

        let mut cfg = if path.is_file() {
            let text = fs::read_to_string(&path)
                .with_context(|| format!("read config {}", path.display()))?;
            let mut c: AppConfig = serde_yaml::from_str(&text)
                .with_context(|| format!("parse config {}", path.display()))?;
            c.expand_all();
            if let Some(cat) = c.catalog.take() {
                c.catalog = Some(resolve_relative(&path, cat));
            }
            c
        } else {
            AppConfig::builtin_defaults()
        };

        cfg.apply_env_overrides();
        cfg.expand_all();
        Ok(cfg)
    }

    /// Built-in defaults when no config file exists.
    // ⟦𓀕𓇇𓂁𓃼⟧ builtin_defaults :: Built-in defaults when no config file exists.
    pub fn builtin_defaults() -> Self {
        let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("/tmp"));
        let mut providers = BTreeMap::new();
        providers.insert(
            "claude".into(),
            ProviderDirs {
                skills_dir: Some(home.join(".claude/skills")),
                agents_dir: Some(home.join(".claude/agents")),
                commands_dir: Some(home.join(".claude/commands")),
            },
        );
        providers.insert(
            "codex".into(),
            ProviderDirs {
                skills_dir: Some(home.join(".codex/skills")),
                agents_dir: None,
                commands_dir: Some(home.join(".codex/commands")),
            },
        );
        providers.insert(
            "grok".into(),
            ProviderDirs {
                skills_dir: Some(home.join(".grok/skills")),
                agents_dir: None,
                commands_dir: None,
            },
        );

        let catalog = dirs::config_dir()
            .unwrap_or_else(|| home.join(".config"))
            .join("skill-manage")
            .join("catalog.yaml");

        Self {
            version: 1,
            sources: SourcesConfig::default(),
            providers,
            catalog: Some(catalog),
            defaults: DefaultsConfig::default(),
        }
    }

    fn apply_env_overrides(&mut self) {
        if let Ok(repo) = env::var("SKILL_REPO") {
            let p = expand_path(PathBuf::from(repo));
            if !self.sources.skills.iter().any(|s| s.path == p) {
                self.sources.skills.push(SourceRoot {
                    path: p,
                    priority: 10,
                });
            }
        }
        if let Ok(repo) = env::var("AGENT_REPO") {
            let p = expand_path(PathBuf::from(repo));
            if !self.sources.agents.iter().any(|s| s.path == p) {
                self.sources.agents.push(SourceRoot {
                    path: p,
                    priority: 10,
                });
            }
        }
        if let Ok(repo) = env::var("COMMAND_REPO") {
            let p = expand_path(PathBuf::from(repo));
            if !self.sources.commands.iter().any(|s| s.path == p) {
                self.sources.commands.push(SourceRoot {
                    path: p,
                    priority: 10,
                });
            }
        }
    }

    fn expand_all(&mut self) {
        for s in &mut self.sources.skills {
            s.path = expand_path(s.path.clone());
        }
        for s in &mut self.sources.agents {
            s.path = expand_path(s.path.clone());
        }
        for s in &mut self.sources.commands {
            s.path = expand_path(s.path.clone());
        }
        for dirs in self.providers.values_mut() {
            if let Some(p) = dirs.skills_dir.take() {
                dirs.skills_dir = Some(expand_path(p));
            }
            if let Some(p) = dirs.agents_dir.take() {
                dirs.agents_dir = Some(expand_path(p));
            }
            if let Some(p) = dirs.commands_dir.take() {
                dirs.commands_dir = Some(expand_path(p));
            }
        }
        if let Some(c) = self.catalog.take() {
            self.catalog = Some(expand_path(c));
        }
    }

    // ⟦𓃟𓋣𓅀𓊏⟧ source_roots :: auto-generated pointer for public function source_roots
    pub fn source_roots(&self, kind: Kind) -> &[SourceRoot] {
        match kind {
            Kind::Skills => &self.sources.skills,
            Kind::Agents => &self.sources.agents,
            Kind::Commands => &self.sources.commands,
        }
    }

    // ⟦𓅖𓎐𓐉𓐋⟧ provider_dirs :: auto-generated pointer for public function provider_dirs
    pub fn provider_dirs(&self, provider: Provider) -> Option<&ProviderDirs> {
        self.providers.get(provider.as_str())
    }

    // ⟦𓐅𓈿𓋆𓇵⟧ kind_dir :: auto-generated pointer for public function kind_dir
    pub fn kind_dir(&self, provider: Provider, kind: Kind) -> Option<PathBuf> {
        let dirs = self.provider_dirs(provider)?;
        match kind {
            Kind::Skills => dirs.skills_dir.clone(),
            Kind::Agents => dirs.agents_dir.clone(),
            Kind::Commands => dirs.commands_dir.clone(),
        }
    }

    /// Whether `path` is under any configured source root for `kind`.
    // ⟦𓊂𓀁𓅆𓀑⟧ is_under_source :: Whether `path` is under any configured source root for `kind`.
    pub fn is_under_source(&self, kind: Kind, path: &Path) -> bool {
        let Ok(canon) = path.canonicalize() else {
            return self
                .source_roots(kind)
                .iter()
                .any(|r| path.starts_with(&r.path));
        };
        for root in self.source_roots(kind) {
            if let Ok(rc) = root.path.canonicalize() {
                if canon.starts_with(&rc) {
                    return true;
                }
            } else if path.starts_with(&root.path) {
                return true;
            }
        }
        false
    }

    // ⟦𓌄𓅓𓇳𓀸⟧ resolve_providers :: auto-generated pointer for public function resolve_providers
    pub fn resolve_providers(&self, provider_flag: Option<&str>) -> Result<Vec<Provider>> {
        let raw = provider_flag
            .map(|s| s.to_string())
            .unwrap_or_else(|| self.defaults.provider.clone());
        if raw.eq_ignore_ascii_case("all") {
            return Ok(Provider::all().to_vec());
        }
        let p: Provider = raw.parse().map_err(|e: String| anyhow::anyhow!(e))?;
        Ok(vec![p])
    }
}

// ⟦𓁋𓉀𓍤𓈰⟧ expand_path :: auto-generated pointer for public function expand_path
pub fn expand_path(path: PathBuf) -> PathBuf {
    let s = path.to_string_lossy().to_string();
    let mut out = s.clone();
    if out.contains("${") {
        for (k, v) in env::vars() {
            let key = format!("${{{k}}}");
            out = out.replace(&key, &v);
        }
    }
    if let Some(rest) = out.strip_prefix("~/") {
        if let Some(home) = dirs::home_dir() {
            return home.join(rest);
        }
    }
    if out == "~" {
        if let Some(home) = dirs::home_dir() {
            return home;
        }
    }
    PathBuf::from(out)
}

fn resolve_relative(config_path: &Path, catalog: PathBuf) -> PathBuf {
    let expanded = expand_path(catalog);
    if expanded.is_absolute() {
        return expanded;
    }
    config_path
        .parent()
        .map(|p| p.join(&expanded))
        .unwrap_or(expanded)
}

/// Write a starter config if missing.
// ⟦𓃪𓌕𓀬𓊋⟧ init_config :: Write a starter config if missing.
pub fn init_config(path: &Path, force: bool) -> Result<()> {
    if path.exists() && !force {
        bail!("config already exists: {}", path.display());
    }
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("~"));
    let monorepo_skills = PathBuf::from("/home/keithbrings/Work/Space/Infra/Noizu/skills");
    let skills_path = if monorepo_skills.is_dir() {
        monorepo_skills.display().to_string()
    } else if let Ok(r) = env::var("SKILL_REPO") {
        r
    } else {
        format!("{}/skills", home.display())
    };
    let body = format!(
        r#"# skill-manage configuration (generated)
version: 1

sources:
  skills:
    - path: {skills}
      priority: 10
  agents:
    - path: {home}/.claude/agents
      priority: 10
  commands:
    - path: {home}/.claude/commands
      priority: 10

providers:
  claude:
    skills_dir: {home}/.claude/skills
    agents_dir: {home}/.claude/agents
    commands_dir: {home}/.claude/commands
  codex:
    skills_dir: {home}/.codex/skills
    commands_dir: {home}/.codex/commands
  grok:
    skills_dir: {home}/.grok/skills

catalog: {home}/.config/skill-manage/catalog.yaml

defaults:
  provider: all
  replace: false
"#,
        skills = skills_path,
        home = home.display(),
    );
    fs::write(path, body)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn expand_tilde() {
        let home = dirs::home_dir().unwrap();
        assert_eq!(expand_path(PathBuf::from("~/foo")), home.join("foo"));
    }
}
