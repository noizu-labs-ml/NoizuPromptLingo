use base64::Engine;
use std::path::Path;

use crate::schema::ParsedPrompt;

#[derive(Debug, Clone)]
pub struct LoadedAttachment {
    pub path: String,
    pub role: String,
    pub mime_type: String,
    pub description: String,
    pub data_b64: String,
}

const MIME_MAP: &[(&str, &str)] = &[
    (".png", "image/png"),
    (".jpg", "image/jpeg"),
    (".jpeg", "image/jpeg"),
    (".webp", "image/webp"),
    (".gif", "image/gif"),
    (".svg", "image/svg+xml"),
    (".mp3", "audio/mp3"),
    (".wav", "audio/wav"),
    (".ogg", "audio/ogg"),
    (".flac", "audio/flac"),
    (".mp4", "video/mp4"),
    (".webm", "video/webm"),
    (".pdf", "application/pdf"),
];

pub fn resolve_mime_type(file_path: &Path, declared: Option<&str>) -> String {
    if let Some(d) = declared {
        return d.to_string();
    }
    let ext = file_path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("");
    let dot_ext = format!(".{}", ext.to_lowercase());
    for &(suffix, mime) in MIME_MAP {
        if dot_ext == suffix {
            return mime.to_string();
        }
    }
    mime_guess::from_path(file_path)
        .first_or_octet_stream()
        .to_string()
}

pub fn load_attachments(prompt: &ParsedPrompt) -> color_eyre::Result<Vec<LoadedAttachment>> {
    let prompt_dir = &prompt.meta.output_dir;
    let mut loaded = Vec::new();

    for att in &prompt.payload.attachments {
        if att.path.is_empty() {
            eprintln!("  \x1b[1;33m\u{26a0}\u{fe0f}  Attachment with no path \u{2014} skipping\x1b[0m");
            continue;
        }

        let abs_path = prompt_dir.join(&att.path);
        let abs_path = abs_path.canonicalize().unwrap_or(abs_path);

        if !abs_path.is_file() {
            color_eyre::eyre::bail!(
                "Attachment not found: {}\n  Referenced from: {}",
                abs_path.display(),
                prompt.meta.path.display()
            );
        }

        let mime = resolve_mime_type(&abs_path, att.mime_type.as_deref());
        let data = std::fs::read(&abs_path)?;
        let data_b64 = base64::engine::general_purpose::STANDARD.encode(&data);

        loaded.push(LoadedAttachment {
            path: abs_path.to_string_lossy().into_owned(),
            role: att.role.clone(),
            mime_type: mime,
            description: att.description.clone().unwrap_or_default(),
            data_b64,
        });
    }

    Ok(loaded)
}

pub fn validate_attachments(prompt: &ParsedPrompt) -> bool {
    let prompt_dir = &prompt.meta.output_dir;
    let mut valid = true;
    for att in &prompt.payload.attachments {
        if att.path.is_empty() {
            continue;
        }
        let abs_path = prompt_dir.join(&att.path);
        if !abs_path.exists() {
            eprintln!(
                "  \x1b[0;31m\u{274c} Attachment not found: {}\x1b[0m",
                abs_path.display()
            );
            valid = false;
        }
    }
    valid
}
