use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::str::FromStr;

// ---------------------------------------------------------------------------
// Quality enum
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Quality {
    Low,
    #[default]
    Medium,
    High,
}

impl Quality {
    pub fn as_str(&self) -> &'static str {
        match self {
            Quality::Low => "low",
            Quality::Medium => "medium",
            Quality::High => "high",
        }
    }
}

impl FromStr for Quality {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "low" => Ok(Quality::Low),
            "medium" | "med" => Ok(Quality::Medium),
            "high" => Ok(Quality::High),
            other => Err(format!("Unknown quality '{}'; expected low|medium|high", other)),
        }
    }
}

// ---------------------------------------------------------------------------
// AudioKind
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum AudioKind {
    Music,
    #[default]
    Voice,
    Sfx,
}

// ---------------------------------------------------------------------------
// PromptPayload (top-level schema struct)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PromptPayload {
    #[serde(default = "default_schema")]
    pub schema: String,
    #[serde(default)]
    pub id: Option<String>,
    #[serde(default = "default_type")]
    pub r#type: String,
    // service is now Option — absent means auto-select
    #[serde(default)]
    pub service: Option<String>,
    #[serde(default)]
    pub model: Option<String>,
    // quality tier (new v0.4)
    #[serde(default)]
    pub quality: Option<String>,
    #[serde(default)]
    pub prompt: PromptSection,
    #[serde(default)]
    pub output: OutputSection,
    #[serde(default)]
    pub requirements: Option<RequirementsSection>,
    #[serde(default)]
    pub attachments: Vec<AttachmentEntry>,
    #[serde(default)]
    pub depends_on: Vec<DependencyRef>,
    #[serde(default)]
    pub post_processing: Vec<PostProcessStep>,
    #[serde(default)]
    pub eval: Option<EvalSection>,
    #[serde(default)]
    pub tags: Vec<String>,
    #[serde(default)]
    pub product_targets: Vec<String>,
}

fn default_schema() -> String {
    "0.1".into()
}
fn default_type() -> String {
    "image".into()
}

// ---------------------------------------------------------------------------
// PromptSection
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PromptSection {
    #[serde(default)]
    pub text: String,
    #[serde(default)]
    pub negative: Option<String>,
    #[serde(default)]
    pub style: Option<String>,
    #[serde(default)]
    pub system: Option<String>,
    #[serde(default)]
    pub provider_options: HashMap<String, serde_yaml::Value>,
    #[serde(default)]
    pub tool_hints: Option<HashMap<String, serde_yaml::Value>>,
}

// ---------------------------------------------------------------------------
// OutputSection
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct OutputSection {
    #[serde(default)]
    pub formats: Vec<FormatEntry>,
    #[serde(default)]
    pub dimensions: Option<DimensionsSection>,
    #[serde(default)]
    pub transparency: Option<String>,
    #[serde(default)]
    pub color_space: Option<String>,
    #[serde(default)]
    pub dpi: Option<u32>,
    #[serde(default)]
    pub diagram_type: Option<String>,
    #[serde(default)]
    pub text_format: Option<String>,
    /// Duration in seconds for video/audio — serde alias "length" for back-compat.
    #[serde(default, alias = "length")]
    pub duration: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct FormatEntry {
    pub format: String,
    #[serde(default)]
    pub quality: Option<u32>,
    #[serde(default)]
    pub filename: Option<String>,
    /// Per-output description. When set, this becomes the generation prompt
    /// for this specific output (with system context prepended), enabling
    /// multi-output prompts where each file has its own creative brief.
    #[serde(default)]
    pub description: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct DimensionsSection {
    #[serde(default)]
    pub width: Option<u32>,
    #[serde(default)]
    pub height: Option<u32>,
    #[serde(default)]
    pub aspect_ratio: Option<String>,
}

// ---------------------------------------------------------------------------
// RequirementsSection (legacy)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct RequirementsSection {
    #[serde(default)]
    pub format: Option<String>,
    #[serde(default)]
    pub dimensions: Option<DimensionsSection>,
}

// ---------------------------------------------------------------------------
// Attachments / Dependencies / Post-processing
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AttachmentEntry {
    pub path: String,
    #[serde(default = "default_role")]
    pub role: String,
    #[serde(default)]
    pub mime_type: Option<String>,
    #[serde(default)]
    pub description: Option<String>,
}

fn default_role() -> String {
    "reference".into()
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum DependencyRef {
    Simple(String),
    Detailed { r#ref: String, r#as: Option<String>, collapse: Option<String> },
}

impl DependencyRef {
    pub fn ref_id(&self) -> &str {
        match self {
            DependencyRef::Simple(s) => s,
            DependencyRef::Detailed { r#ref, .. } => r#ref,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PostProcessStep {
    pub action: String,
    #[serde(default)]
    pub params: HashMap<String, serde_yaml::Value>,
}

// ---------------------------------------------------------------------------
// EvalSection / EvalCriterion
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EvalSection {
    #[serde(default)]
    pub pass_threshold: Option<f64>,
    #[serde(default)]
    pub max_attempts: Option<usize>,
    #[serde(default)]
    pub required_pass: Vec<String>,
    #[serde(default)]
    pub criteria: HashMap<String, EvalCriterion>,
    #[serde(default)]
    pub reject_if: Vec<String>,
}

impl EvalSection {
    pub fn effective_pass_threshold(&self) -> f64 {
        self.pass_threshold.unwrap_or(0.7)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EvalCriterion {
    #[serde(default)]
    pub weight: Option<f64>,
    #[serde(default)]
    pub scale: Option<Vec<u32>>,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub fail_signals: Vec<String>,
}

// ---------------------------------------------------------------------------
// PromptMeta (resolved, runtime metadata)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct PromptMeta {
    pub path: PathBuf,
    pub asset_type: AssetType,
    pub audio_kind: AudioKind,
    pub output_formats: Vec<FormatEntry>,
    pub name_stem: String,
    pub output_dir: PathBuf,
    pub id: String,
    /// Pinned service from YAML (None = auto-select)
    pub service: Option<String>,
    pub model: Option<String>,
    pub schema_version: String,
    pub quality: Quality,
    pub duration: Option<f64>,
}

// ---------------------------------------------------------------------------
// AssetType
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AssetType {
    Image,
    Audio,
    Video,
    Component,
    ReactPage,
    Html,
    StyleGuide,
    Diagram,
    Document,
    Unknown,
}

impl AssetType {
    pub fn from_extension(ext: &str) -> Self {
        match ext.to_lowercase().as_str() {
            "png" | "jpg" | "jpeg" | "svg" | "webp" => AssetType::Image,
            "mp3" | "wav" | "ogg" | "flac" => AssetType::Audio,
            "mp4" | "webm" | "avi" | "mov" => AssetType::Video,
            "ts" | "tsx" | "js" | "jsx" => AssetType::Component,
            _ => AssetType::Unknown,
        }
    }

    pub fn from_type_str(s: &str) -> (Self, AudioKind) {
        match s {
            "image" => (AssetType::Image, AudioKind::Voice),
            "audio" | "voice" => (AssetType::Audio, AudioKind::Voice),
            "music" => (AssetType::Audio, AudioKind::Music),
            "sfx" => (AssetType::Audio, AudioKind::Sfx),
            "video" => (AssetType::Video, AudioKind::Voice),
            "component" => (AssetType::Component, AudioKind::Voice),
            "react-page" => (AssetType::ReactPage, AudioKind::Voice),
            "html" => (AssetType::Html, AudioKind::Voice),
            "style-guide" => (AssetType::StyleGuide, AudioKind::Voice),
            "diagram" => (AssetType::Diagram, AudioKind::Voice),
            "document" => (AssetType::Document, AudioKind::Voice),
            _ => (AssetType::Unknown, AudioKind::Voice),
        }
    }

    pub fn default_extension(&self) -> &str {
        match self {
            AssetType::Image => "png",
            AssetType::Audio => "mp3",
            AssetType::Video => "mp4",
            AssetType::Component => "ts",
            AssetType::ReactPage => "tsx",
            AssetType::Html => "html",
            AssetType::StyleGuide => "html",
            AssetType::Diagram => "mmd",
            AssetType::Document => "md",
            AssetType::Unknown => "bin",
        }
    }

    /// True for chat-based generation types.
    pub fn is_chat_type(&self) -> bool {
        matches!(
            self,
            AssetType::Component
                | AssetType::ReactPage
                | AssetType::Html
                | AssetType::StyleGuide
                | AssetType::Diagram
                | AssetType::Document
        )
    }
}

// ---------------------------------------------------------------------------
// ParsedPrompt
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct ParsedPrompt {
    pub payload: PromptPayload,
    pub meta: PromptMeta,
}

// ---------------------------------------------------------------------------
// Public helpers
// ---------------------------------------------------------------------------

pub fn is_media_prompt(path: &Path) -> bool {
    path.file_name()
        .and_then(|n| n.to_str())
        .map(|n| n.ends_with(".media.prompt"))
        .unwrap_or(false)
}

pub fn parse_prompt_file(path: &Path) -> color_eyre::Result<ParsedPrompt> {
    let path = path.canonicalize().unwrap_or_else(|_| path.to_path_buf());
    let content = std::fs::read_to_string(&path)
        .map_err(|e| color_eyre::eyre::eyre!("Failed to read {}: {}", path.display(), e))?;

    let mut payload: PromptPayload = serde_yaml::from_str(&content)
        .map_err(|e| color_eyre::eyre::eyre!("YAML parse error in {}: {}", path.display(), e))?;

    normalize_to_v03(&mut payload);

    let (asset_type, audio_kind, output_formats) = detect_asset_info(&path, &payload);

    let name_stem = if is_media_prompt(&path) {
        let name = path.file_name().unwrap().to_str().unwrap();
        name.strip_suffix(".media.prompt").unwrap().to_string()
    } else {
        let name = path.file_name().unwrap().to_str().unwrap();
        let base = name.strip_suffix(".prompt").unwrap();
        base.rsplit_once('.').map(|(stem, _)| stem).unwrap_or(base).to_string()
    };

    let output_dir = path.parent().unwrap_or(Path::new(".")).to_path_buf();
    let id = payload.id.clone().unwrap_or_else(|| name_stem.clone());

    // Resolve quality: YAML > default Medium
    let quality = payload
        .quality
        .as_deref()
        .and_then(|q| q.parse().ok())
        .unwrap_or(Quality::Medium);

    // Resolve duration from output section
    let duration = payload.output.duration;

    let meta = PromptMeta {
        path: path.clone(),
        asset_type,
        audio_kind,
        output_formats,
        name_stem,
        output_dir,
        id,
        service: payload.service.clone(),
        model: payload.model.clone(),
        schema_version: payload.schema.clone(),
        quality,
        duration,
    };

    Ok(ParsedPrompt { payload, meta })
}

fn normalize_to_v03(payload: &mut PromptPayload) {
    // v0.4 and v0.3 share the same tool_hints → provider_options path
    if payload.schema.starts_with("0.3") || payload.schema.starts_with("0.4") {
        if let Some(hints) = payload.prompt.tool_hints.take() {
            if payload.prompt.provider_options.is_empty() {
                payload.prompt.provider_options = hints;
            }
        }
        return;
    }

    // Legacy normalization
    if let Some(ref reqs) = payload.requirements {
        if let Some(ref fmt) = reqs.format {
            if payload.output.formats.is_empty() {
                payload.output.formats.push(FormatEntry {
                    format: fmt.clone(),
                    quality: None,
                    filename: None,
                    description: None,
                });
            }
        }
        if payload.output.dimensions.is_none() {
            payload.output.dimensions = reqs.dimensions.clone();
        }
    }

    if let Some(hints) = payload.prompt.tool_hints.take() {
        if payload.prompt.provider_options.is_empty() {
            payload.prompt.provider_options = hints;
        }
    }
}

fn detect_asset_info(path: &Path, payload: &PromptPayload) -> (AssetType, AudioKind, Vec<FormatEntry>) {
    if is_media_prompt(path) {
        let (asset_type, audio_kind) = AssetType::from_type_str(&payload.r#type);
        let formats = if !payload.output.formats.is_empty() {
            payload.output.formats.clone()
        } else if let Some(ref reqs) = payload.requirements {
            if let Some(ref fmt) = reqs.format {
                vec![FormatEntry { format: fmt.clone(), quality: None, filename: None, description: None }]
            } else {
                vec![FormatEntry { format: asset_type.default_extension().into(), quality: None, filename: None, description: None }]
            }
        } else {
            vec![FormatEntry { format: asset_type.default_extension().into(), quality: None, filename: None, description: None }]
        };
        (asset_type, audio_kind, formats)
    } else {
        let name = path.file_name().unwrap().to_str().unwrap();
        let base = name.strip_suffix(".prompt").unwrap();
        let ext = base.rsplit_once('.').map(|(_, e)| e).unwrap_or("png");
        let asset_type = AssetType::from_extension(ext);
        (asset_type, AudioKind::Voice, vec![FormatEntry { format: ext.into(), quality: None, filename: None, description: None }])
    }
}
