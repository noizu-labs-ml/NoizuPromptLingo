use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::schema::ParsedPrompt;

/// Returns (output_path, per_output_description) pairs.
/// When a format entry has a `description`, it becomes the generation prompt
/// for that specific output, enabling multi-output prompts (e.g. SFX collections).
pub fn resolve_output_paths(prompt: &ParsedPrompt) -> Vec<(PathBuf, Option<String>)> {
    let meta = &prompt.meta;
    meta.output_formats
        .iter()
        .map(|fmt| {
            let stem = fmt.filename.as_deref().unwrap_or(&meta.name_stem);
            let path = meta.output_dir.join(format!("{}.{}", stem, fmt.format));
            (path, fmt.description.clone())
        })
        .collect()
}

pub fn genai_dir_for(output_path: &Path) -> PathBuf {
    let name = output_path.file_name().unwrap().to_str().unwrap();
    output_path.parent().unwrap().join(format!(".genai.{}", name))
}

pub fn genai_candidate_path(output_path: &Path) -> PathBuf {
    let gdir = genai_dir_for(output_path);
    std::fs::create_dir_all(&gdir).ok();
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let hex: String = (0..4)
        .map(|_| format!("{:02x}", rand_byte()))
        .collect();
    let ext = output_path.extension().unwrap_or_default().to_str().unwrap();
    gdir.join(format!("{}_{}.{}", ts, hex, ext))
}

pub fn link_active(genai_path: &Path, output_path: &Path) -> color_eyre::Result<()> {
    if output_path.exists() || output_path.is_symlink() {
        std::fs::remove_file(output_path)?;
    }
    std::fs::hard_link(genai_path, output_path)?;
    Ok(())
}

/// Write a metadata sidecar file next to a generated candidate.
/// Path: same as candidate but with `.metadata.yaml` replacing the extension.
pub fn write_metadata(
    genai_path: &Path,
    service: &str,
    model: &str,
    prompt_text: &str,
    negative: Option<&str>,
    eval_score: Option<f64>,
    eval_notes: Option<&str>,
    options: &std::collections::HashMap<String, serde_yaml::Value>,
) {
    let meta_path = genai_path.with_extension("metadata.yaml");
    let mut content = String::new();
    content.push_str(&format!("service: {}\n", service));
    content.push_str(&format!("model: {}\n", model));
    content.push_str(&format!("timestamp: {}\n",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs()
    ));
    if let Some(score) = eval_score {
        content.push_str(&format!("eval_score: {:.3}\n", score));
    }
    if let Some(notes) = eval_notes {
        let escaped = notes.replace('\\', "\\\\").replace('"', "\\\"");
        content.push_str(&format!("eval_notes: \"{}\"\n", &escaped[..escaped.len().min(500)]));
    }
    if !options.is_empty() {
        content.push_str("provider_options:\n");
        for (k, v) in options {
            content.push_str(&format!("  {}: {:?}\n", k, v));
        }
    }
    content.push_str("prompt: |\n");
    for line in prompt_text.lines() {
        content.push_str(&format!("  {}\n", line));
    }
    if let Some(neg) = negative {
        if !neg.is_empty() {
            content.push_str("negative: |\n");
            for line in neg.lines() {
                content.push_str(&format!("  {}\n", line));
            }
        }
    }
    let _ = std::fs::write(&meta_path, content);
}

fn rand_byte() -> u8 {
    use std::hash::{Hash, Hasher};
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    SystemTime::now().hash(&mut hasher);
    std::thread::current().id().hash(&mut hasher);
    (hasher.finish() & 0xFF) as u8
}
