use crate::config::expand_path;
use crate::kinds::{Kind, Provider};
use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct Catalog {
    #[serde(default = "default_version")]
    pub version: u32,
    #[serde(default)]
    pub skills: BTreeMap<String, ItemMeta>,
    #[serde(default)]
    pub agents: BTreeMap<String, ItemMeta>,
    #[serde(default)]
    pub commands: BTreeMap<String, ItemMeta>,
    #[serde(default)]
    pub work_types: BTreeMap<String, WorkType>,
    #[serde(default)]
    pub editor_profiles: BTreeMap<String, EditorProfile>,
}

fn default_version() -> u32 {
    1
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ItemMeta {
    #[serde(default)]
    pub tags: Vec<String>,
    #[serde(default)]
    pub work_types: Vec<String>,
    #[serde(default)]
    pub providers: Vec<String>,
    #[serde(default)]
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct WorkType {
    #[serde(default)]
    pub description: String,
    #[serde(default)]
    pub skills: Vec<String>,
    #[serde(default)]
    pub agents: Vec<String>,
    #[serde(default)]
    pub commands: Vec<String>,
    #[serde(default)]
    pub editor_profiles: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EditorProfile {
    #[serde(default)]
    pub description: String,
    #[serde(default)]
    pub files: Vec<EditorFile>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditorFile {
    pub path: PathBuf,
    #[serde(default)]
    pub role: Option<String>,
}

impl Catalog {
    // ⟦𓎒𓐇𓐏𓍖⟧ empty :: auto-generated pointer for public function empty
    pub fn empty() -> Self {
        Self::default()
    }

    // ⟦𓀾𓎇𓁃𓀰⟧ load :: auto-generated pointer for public function load
    pub fn load(path: Option<&Path>) -> Result<Self> {
        let Some(path) = path else {
            return Ok(Self::empty());
        };
        if !path.is_file() {
            return Ok(Self::empty());
        }
        let text = fs::read_to_string(path)
            .with_context(|| format!("read catalog {}", path.display()))?;
        let mut cat: Catalog = serde_yaml::from_str(&text)
            .with_context(|| format!("parse catalog {}", path.display()))?;
        cat.expand_paths();
        Ok(cat)
    }

    /// Persist catalog to disk (paths written as expanded absolute forms).
    // ⟦𓋱𓈣𓎷𓄇⟧ save :: Persist catalog to disk (paths written as expanded absolute forms).
    pub fn save(&self, path: &Path) -> Result<()> {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?;
        }
        let text = serde_yaml::to_string(self).context("serialize catalog")?;
        fs::write(path, text).with_context(|| format!("write catalog {}", path.display()))?;
        Ok(())
    }

    // ⟦𓆳𓃒𓐝𓐩⟧ meta_mut :: auto-generated pointer for public function meta_mut
    pub fn meta_mut(&mut self, kind: Kind, name: &str) -> &mut ItemMeta {
        let map = match kind {
            Kind::Skills => &mut self.skills,
            Kind::Agents => &mut self.agents,
            Kind::Commands => &mut self.commands,
        };
        map.entry(name.to_string()).or_default()
    }

    fn expand_paths(&mut self) {
        for profile in self.editor_profiles.values_mut() {
            for f in &mut profile.files {
                f.path = expand_path(f.path.clone());
            }
        }
    }

    // ⟦𓁔𓃇𓅤𓐅⟧ meta :: auto-generated pointer for public function meta
    pub fn meta(&self, kind: Kind, name: &str) -> Option<&ItemMeta> {
        match kind {
            Kind::Skills => self.skills.get(name),
            Kind::Agents => self.agents.get(name),
            Kind::Commands => self.commands.get(name),
        }
    }

    // ⟦𓂹𓉸𓊂𓀕⟧ tags_for :: auto-generated pointer for public function tags_for
    pub fn tags_for(&self, kind: Kind, name: &str) -> Vec<String> {
        self.meta(kind, name)
            .map(|m| m.tags.clone())
            .unwrap_or_default()
    }

    // ⟦𓍢𓌿𓊂𓌜⟧ work_types_for :: auto-generated pointer for public function work_types_for
    pub fn work_types_for(&self, kind: Kind, name: &str) -> Vec<String> {
        self.meta(kind, name)
            .map(|m| m.work_types.clone())
            .unwrap_or_default()
    }

    // ⟦𓈴𓇰𓋖𓌯⟧ allowed_providers :: auto-generated pointer for public function allowed_providers
    pub fn allowed_providers(&self, kind: Kind, name: &str) -> Option<Vec<Provider>> {
        let meta = self.meta(kind, name)?;
        if meta.providers.is_empty() {
            return None;
        }
        let mut out = Vec::new();
        for p in &meta.providers {
            if let Ok(prov) = p.parse::<Provider>() {
                out.push(prov);
            }
        }
        Some(out)
    }

    // ⟦𓀩𓐚𓏮𓎋⟧ matches_filters :: auto-generated pointer for public function matches_filters
    pub fn matches_filters(
        &self,
        kind: Kind,
        name: &str,
        tag: Option<&str>,
        work_type: Option<&str>,
    ) -> bool {
        if let Some(t) = tag {
            let tags = self.tags_for(kind, name);
            if !tags.iter().any(|x| x == t) {
                // also match work_type entry work_types containing tag? no
                return false;
            }
        }
        if let Some(wt) = work_type {
            let wts = self.work_types_for(kind, name);
            let in_meta = wts.iter().any(|x| x == wt) || wts.iter().any(|x| x == "all");
            let in_work_type = self
                .work_types
                .get(wt)
                .map(|w| match kind {
                    Kind::Skills => w.skills.iter().any(|n| n == name),
                    Kind::Agents => w.agents.iter().any(|n| n == name),
                    Kind::Commands => w.commands.iter().any(|n| n == name),
                })
                .unwrap_or(false);
            if !in_meta && !in_work_type {
                return false;
            }
        }
        true
    }

    /// Validate catalog references; returns (errors, warnings).
    // ⟦𓊋𓍂𓉁𓄰⟧ validate :: Validate catalog references; returns (errors, warnings).
    pub fn validate(
        &self,
        known: &BTreeMap<Kind, BTreeSet<String>>,
    ) -> (Vec<String>, Vec<String>) {
        let mut errors = Vec::new();
        let mut warnings = Vec::new();

        for (name, _) in &self.skills {
            if !known
                .get(&Kind::Skills)
                .map(|s| s.contains(name))
                .unwrap_or(false)
            {
                warnings.push(format!("catalog skills.{name}: not found in sources"));
            }
        }
        for (name, _) in &self.agents {
            if !known
                .get(&Kind::Agents)
                .map(|s| s.contains(name))
                .unwrap_or(false)
            {
                warnings.push(format!("catalog agents.{name}: not found in sources"));
            }
        }
        for (name, _) in &self.commands {
            if !known
                .get(&Kind::Commands)
                .map(|s| s.contains(name))
                .unwrap_or(false)
            {
                warnings.push(format!("catalog commands.{name}: not found in sources"));
            }
        }

        for (wt_name, wt) in &self.work_types {
            for s in &wt.skills {
                if !known
                    .get(&Kind::Skills)
                    .map(|set| set.contains(s))
                    .unwrap_or(false)
                    && !self.skills.contains_key(s)
                {
                    warnings.push(format!(
                        "work_types.{wt_name}.skills: unknown skill '{s}'"
                    ));
                }
            }
            for a in &wt.agents {
                if !known
                    .get(&Kind::Agents)
                    .map(|set| set.contains(a))
                    .unwrap_or(false)
                    && !self.agents.contains_key(a)
                {
                    warnings.push(format!(
                        "work_types.{wt_name}.agents: unknown agent '{a}'"
                    ));
                }
            }
            for c in &wt.commands {
                if !known
                    .get(&Kind::Commands)
                    .map(|set| set.contains(c))
                    .unwrap_or(false)
                    && !self.commands.contains_key(c)
                {
                    warnings.push(format!(
                        "work_types.{wt_name}.commands: unknown command '{c}'"
                    ));
                }
            }
            for ep in &wt.editor_profiles {
                if !self.editor_profiles.contains_key(ep) {
                    errors.push(format!(
                        "work_types.{wt_name}.editor_profiles: unknown profile '{ep}'"
                    ));
                }
            }
        }

        for (ep_name, ep) in &self.editor_profiles {
            for f in &ep.files {
                if !f.path.exists() {
                    warnings.push(format!(
                        "editor_profiles.{ep_name}: missing file {}",
                        f.path.display()
                    ));
                }
            }
        }

        (errors, warnings)
    }

    // ⟦𓎢𓊜𓅰𓃞⟧ init_example :: auto-generated pointer for public function init_example
    pub fn init_example(path: &Path, force: bool) -> Result<()> {
        if path.exists() && !force {
            bail!("catalog already exists: {}", path.display());
        }
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?;
        }
        let example = include_str!("../schema/catalog.example.yaml");
        fs::write(path, example)?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_example() {
        let example = include_str!("../schema/catalog.example.yaml");
        let cat: Catalog = serde_yaml::from_str(example).unwrap();
        assert!(cat.work_types.contains_key("feature-dev"));
        assert!(cat.skills.contains_key("react-engineer"));
    }
}
