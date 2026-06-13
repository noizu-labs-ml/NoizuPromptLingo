use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::schema::ParsedPrompt;

pub fn resolve_output_paths(prompt: &ParsedPrompt) -> Vec<PathBuf> {
    let meta = &prompt.meta;
    meta.output_formats
        .iter()
        .map(|fmt| {
            let stem = fmt.filename.as_deref().unwrap_or(&meta.name_stem);
            meta.output_dir.join(format!("{}.{}", stem, fmt.format))
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

fn rand_byte() -> u8 {
    use std::hash::{Hash, Hasher};
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    SystemTime::now().hash(&mut hasher);
    std::thread::current().id().hash(&mut hasher);
    (hasher.finish() & 0xFF) as u8
}
