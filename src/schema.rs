use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PromptPayload {
    #[serde(default = "default_schema")]
    pub schema: String,
    #[serde(default)]
    pub id: Option<String>,
    #[serde(default = "default_type")]
    pub r#type: String,
    #[serde(default = "default_service")]
    pub service: String,
    #[serde(default)]
    pub model: Option<String>,
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
fn default_service() -> String {
    "gemini".into()
}

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
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct FormatEntry {
    pub format: String,
    #[serde(default)]
    pub quality: Option<u32>,
    #[serde(default)]
    pub filename: Option<String>,
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

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct RequirementsSection {
    #[serde(default)]
    pub format: Option<String>,
    #[serde(default)]
    pub dimensions: Option<DimensionsSection>,
}

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

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EvalSection {
    #[serde(default)]
    pub pass_threshold: Option<f64>,
    #[serde(default)]
    pub required_pass: Vec<String>,
    #[serde(default)]
    pub criteria: HashMap<String, EvalCriterion>,
    #[serde(default)]
    pub reject_if: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EvalCriterion {
    #[serde(default)]
    pub weight: Option<f64>,
    #[serde(default)]
    pub scale: Option<Vec<u32>>,
    #[serde(default)]
    pub description: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PromptMeta {
    pub path: PathBuf,
    pub asset_type: AssetType,
    pub output_formats: Vec<FormatEntry>,
    pub name_stem: String,
    pub output_dir: PathBuf,
    pub id: String,
    pub service: String,
    pub model: Option<String>,
    pub schema_version: String,
}

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

    pub fn from_type_str(s: &str) -> Self {
        match s {
            "image" => AssetType::Image,
            "audio" => AssetType::Audio,
            "video" => AssetType::Video,
            "component" => AssetType::Component,
            "react-page" => AssetType::ReactPage,
            "html" => AssetType::Html,
            "style-guide" => AssetType::StyleGuide,
            "diagram" => AssetType::Diagram,
            "document" => AssetType::Document,
            _ => AssetType::Unknown,
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
}

#[derive(Debug, Clone)]
pub struct ParsedPrompt {
    pub payload: PromptPayload,
    pub meta: PromptMeta,
}

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

    let (asset_type, output_formats) = detect_asset_info(&path, &payload);

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

    let meta = PromptMeta {
        path: path.clone(),
        asset_type,
        output_formats,
        name_stem,
        output_dir,
        id,
        service: payload.service.clone(),
        model: payload.model.clone(),
        schema_version: payload.schema.clone(),
    };

    Ok(ParsedPrompt { payload, meta })
}

fn normalize_to_v03(payload: &mut PromptPayload) {
    if payload.schema.starts_with("0.3") {
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

fn detect_asset_info(path: &Path, payload: &PromptPayload) -> (AssetType, Vec<FormatEntry>) {
    if is_media_prompt(path) {
        let asset_type = AssetType::from_type_str(&payload.r#type);
        let formats = if !payload.output.formats.is_empty() {
            payload.output.formats.clone()
        } else if let Some(ref reqs) = payload.requirements {
            if let Some(ref fmt) = reqs.format {
                vec![FormatEntry { format: fmt.clone(), quality: None, filename: None }]
            } else {
                vec![FormatEntry { format: asset_type.default_extension().into(), quality: None, filename: None }]
            }
        } else {
            vec![FormatEntry { format: asset_type.default_extension().into(), quality: None, filename: None }]
        };
        (asset_type, formats)
    } else {
        let name = path.file_name().unwrap().to_str().unwrap();
        let base = name.strip_suffix(".prompt").unwrap();
        let ext = base.rsplit_once('.').map(|(_, e)| e).unwrap_or("png");
        let asset_type = AssetType::from_extension(ext);
        (asset_type, vec![FormatEntry { format: ext.into(), quality: None, filename: None }])
    }
}
