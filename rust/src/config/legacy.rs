use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct SecretsConfigLegacy {
    /// List of Infisical folder paths to ensure exist
    #[serde(default)]
    pub folders: Vec<String>,
    /// Variable definitions: name → spec
    #[serde(default)]
    pub variables: HashMap<String, LegacyVarSpec>,
    /// Folder → key → variable name mappings
    #[serde(default)]
    pub mappings: HashMap<String, HashMap<String, String>>,
}

/// A variable spec in legacy format
#[derive(Deserialize, Serialize, Debug, Clone)]
#[serde(untagged)]
pub enum LegacyVarSpec {
    Inline(String),
    Structured(LegacyVarDef),
}

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct LegacyVarDef {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub env: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub generate: Option<String>, // "password", "hex", "django"
    #[serde(skip_serializing_if = "Option::is_none")]
    pub inherit: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub eval: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub default: Option<String>,
    #[serde(default)]
    pub optional: bool,
}
