use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct SecretsConfigV1 {
    #[serde(rename = "apiVersion")]
    pub api_version: String,
    pub sections: Vec<Section>,
    #[serde(default)]
    pub groups: HashMap<String, Vec<String>>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Section {
    pub id: String,
    pub title: String,
    pub path: String,
    #[serde(default)]
    pub vars: HashMap<String, SecretSpec>,
    #[serde(default)]
    pub secrets: HashMap<String, SecretSpec>,
}

/// A secret spec — the union of all field combinations the YAML supports
#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct SecretSpec {
    /// `dc: {scope: "secrets", path: "infisical.host"}`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub dc: Option<DcRef>,
    /// `env: MY_VAR`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub env: Option<String>,
    /// `ref: other_secret_name`
    #[serde(rename = "ref", skip_serializing_if = "Option::is_none")]
    pub ref_: Option<String>,
    /// `template: "{{VAR_ONE}}-{{VAR_TWO}}"`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub template: Option<String>,
    /// `file: path/to/file`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub file: Option<String>,
    /// `default: value`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default: Option<String>,
    /// `fallback_dc: {scope, path}`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub fallback_dc: Option<DcRef>,
    /// `override: ENV_VAR` — env var that overrides everything
    #[serde(rename = "override", skip_serializing_if = "Option::is_none")]
    pub override_: Option<String>,
    /// `auto: {type: "password|hex|django", length: 32}`
    #[serde(skip_serializing_if = "Option::is_none")]
    pub auto: Option<AutoSpec>,
    /// If true, missing value is not an error
    #[serde(default)]
    pub optional: bool,
    /// `decode: base64` — decode after fetching
    #[serde(skip_serializing_if = "Option::is_none")]
    pub decode: Option<String>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct DcRef {
    pub scope: String,
    pub path: String,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct AutoSpec {
    #[serde(rename = "type")]
    pub kind: AutoKind,
    #[serde(default = "default_length")]
    pub length: usize,
}

#[derive(Deserialize, Serialize, Debug, Clone, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum AutoKind {
    Password,
    Hex,
    Django,
}

fn default_length() -> usize {
    32
}

impl SecretsConfigV1 {
    /// Return all section IDs in a group, or error if not found
    pub fn resolve_group(&self, name: &str) -> Option<Vec<&Section>> {
        if let Some(ids) = self.groups.get(name) {
            let sections: Vec<&Section> = ids
                .iter()
                .filter_map(|id| self.sections.iter().find(|s| &s.id == id))
                .collect();
            if !sections.is_empty() {
                return Some(sections);
            }
        }
        None
    }

    /// Find section by id
    pub fn section(&self, id: &str) -> Option<&Section> {
        self.sections.iter().find(|s| s.id == id)
    }

    /// All section paths
    pub fn all_paths(&self) -> Vec<&str> {
        self.sections.iter().map(|s| s.path.as_str()).collect()
    }
}
