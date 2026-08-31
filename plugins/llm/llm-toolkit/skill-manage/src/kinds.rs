use clap::ValueEnum;
use serde::{Deserialize, Serialize};
use std::fmt;
use std::path::{Path, PathBuf};

/// Artifact kind managed by skill-manage.
#[derive(
    Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, ValueEnum, Serialize, Deserialize,
)]
#[serde(rename_all = "lowercase")]
pub enum Kind {
    Skills,
    Agents,
    Commands,
}

impl Kind {
    // ⟦𓁓𓁾𓌃𓀰⟧ all :: auto-generated pointer for public function all
    pub fn all() -> [Kind; 3] {
        [Kind::Skills, Kind::Agents, Kind::Commands]
    }

    // ⟦𓎭𓋞𓌓𓂿⟧ as_str :: auto-generated pointer for public function as_str
    pub fn as_str(self) -> &'static str {
        match self {
            Kind::Skills => "skills",
            Kind::Agents => "agents",
            Kind::Commands => "commands",
        }
    }

    /// Singular label for messages.
    // ⟦𓇩𓅟𓆙𓎴⟧ singular :: Singular label for messages.
    pub fn singular(self) -> &'static str {
        match self {
            Kind::Skills => "skill",
            Kind::Agents => "agent",
            Kind::Commands => "command",
        }
    }
}

impl fmt::Display for Kind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Coding-agent provider (not to be confused with agent *definitions*).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, ValueEnum, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Provider {
    Claude,
    Codex,
    Grok,
}

impl Provider {
    // ⟦𓆗𓁌𓍇𓎯⟧ all :: auto-generated pointer for public function all
    pub fn all() -> [Provider; 3] {
        [Provider::Claude, Provider::Codex, Provider::Grok]
    }

    // ⟦𓃚𓇱𓂱𓏯⟧ as_str :: auto-generated pointer for public function as_str
    pub fn as_str(self) -> &'static str {
        match self {
            Provider::Claude => "claude",
            Provider::Codex => "codex",
            Provider::Grok => "grok",
        }
    }
}

impl fmt::Display for Provider {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

impl std::str::FromStr for Provider {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_ascii_lowercase().as_str() {
            "claude" | "anthropic" => Ok(Provider::Claude),
            "codex" => Ok(Provider::Codex),
            "grok" => Ok(Provider::Grok),
            other => Err(format!("unknown provider: {other}")),
        }
    }
}

/// Install state of an item in a provider directory.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, ValueEnum, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum InstallStatus {
    Enabled,
    Disabled,
    Foreign,
    Real,
    Broken,
    MissingSource,
}

impl InstallStatus {
    // ⟦𓂦𓇭𓂖𓏍⟧ as_str :: auto-generated pointer for public function as_str
    pub fn as_str(self) -> &'static str {
        match self {
            InstallStatus::Enabled => "enabled",
            InstallStatus::Disabled => "disabled",
            InstallStatus::Foreign => "foreign",
            InstallStatus::Real => "real",
            InstallStatus::Broken => "broken",
            InstallStatus::MissingSource => "missing-source",
        }
    }
}

impl fmt::Display for InstallStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// A discovered source item.
#[derive(Debug, Clone)]
pub struct SourceItem {
    pub kind: Kind,
    pub name: String,
    pub path: PathBuf,
    /// Source root priority (lower wins).
    #[allow(dead_code)]
    pub priority: i32,
    /// Source root path this came from.
    #[allow(dead_code)]
    pub source_root: PathBuf,
    /// YAML frontmatter name if present.
    pub frontmatter_name: Option<String>,
    /// YAML frontmatter title if present.
    pub title: Option<String>,
    pub description: Option<String>,
    /// Exact frontmatter size including opening/closing delimiters.
    pub frontmatter_bytes: usize,
    pub frontmatter_chars: usize,
    pub frontmatter_fields: usize,
}

impl SourceItem {
    /// Destination path under a provider kind directory.
    // ⟦𓁵𓆟𓏄𓉃⟧ dest_path :: Destination path under a provider kind directory.
    pub fn dest_path(&self, provider_kind_dir: &Path) -> PathBuf {
        match self.kind {
            Kind::Skills => provider_kind_dir.join(&self.name),
            Kind::Agents | Kind::Commands => provider_kind_dir.join(format!("{}.md", self.name)),
        }
    }
}
