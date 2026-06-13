use std::path::{Path, PathBuf};
use anyhow::{Context, Result};
use sha2::{Sha256, Digest};

/// Root state directory for all dc stores.
pub fn state_dir() -> PathBuf {
    if let Ok(xdg) = std::env::var("XDG_STATE_HOME") {
        PathBuf::from(xdg).join("direnv-config")
    } else if let Some(home) = dirs::home_dir() {
        home.join(".local").join("state").join("direnv-config")
    } else {
        // Last resort fallback
        PathBuf::from("/tmp/direnv-config")
    }
}

/// Convert an absolute directory path to a store directory name.
///
/// Scheme: strip leading `/`, replace `/` with `-`.
/// If the result exceeds 200 characters, truncate to 200 and append
/// `-` plus the first 8 hex characters of the SHA-256 of the full path.
pub fn path_to_hash(dir: &Path) -> String {
    let s = dir.to_string_lossy();
    let stripped = s.strip_prefix('/').unwrap_or(&s);
    let name = stripped.replace('/', "-");

    if name.len() <= 200 {
        name
    } else {
        let mut hasher = Sha256::new();
        hasher.update(s.as_bytes());
        let hash = hasher.finalize();
        let hex = format!("{:x}", hash);
        format!("{}-{}", &name[..200], &hex[..8])
    }
}

/// Return the store path for a given directory.
pub fn store_path(dir: &Path) -> PathBuf {
    state_dir().join(path_to_hash(dir))
}

/// Return the config subdirectory inside a store.
pub fn config_dir(store: &Path, name: &str) -> PathBuf {
    store.join(name)
}

/// Return the path to a specific layer file.
pub fn layer_path(store: &Path, name: &str, layer: &str) -> PathBuf {
    store.join(name).join(format!("{}.yaml", layer))
}

/// Return the path to the .active file for a named config.
pub fn active_path(store: &Path, name: &str) -> PathBuf {
    store.join(name).join(".active")
}

/// Create the store directory and initialize .meta if it does not exist.
/// Returns the store path.
pub fn ensure_store(dir: &Path) -> Result<PathBuf> {
    let sp = store_path(dir);
    std::fs::create_dir_all(&sp)
        .with_context(|| format!("failed to create store directory: {}", sp.display()))?;

    let meta_path = sp.join(".meta");
    if !meta_path.exists() {
        let meta = crate::store::meta::StoreMeta {
            source: dir.to_path_buf(),
            created: chrono::Utc::now().to_rfc3339(),
            parent: None,
            configs: Vec::new(),
        };
        crate::store::meta::write_meta(&sp, &meta)?;
    }
    Ok(sp)
}

/// Create the named config subdirectory inside a store if it does not exist.
/// Returns the config directory path.
pub fn ensure_config(store: &Path, name: &str) -> Result<PathBuf> {
    let cd = config_dir(store, name);
    std::fs::create_dir_all(&cd)
        .with_context(|| format!("failed to create config directory: {}", cd.display()))?;
    Ok(cd)
}

/// Find the store for the current working directory.
///
/// Walks up the directory tree from CWD until it finds a directory
/// that has a corresponding store, similar to how git searches for `.git`.
pub fn find_current_store() -> Result<PathBuf> {
    let cwd = std::env::current_dir().context("failed to get current directory")?;
    let mut dir = cwd.as_path();
    loop {
        let sp = store_path(dir);
        if sp.exists() {
            return Ok(sp);
        }
        match dir.parent() {
            Some(parent) if !parent.as_os_str().is_empty() => dir = parent,
            _ => break,
        }
    }
    anyhow::bail!(
        "no store found for {} (searched all parent directories). Run `dc init` first.",
        cwd.display()
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    #[test]
    fn path_to_hash_simple() {
        let p = Path::new("/Users/keith/Github/k8/projects");
        let h = path_to_hash(p);
        assert_eq!(h, "Users-keith-Github-k8-projects");
    }

    #[test]
    fn path_to_hash_root() {
        let h = path_to_hash(Path::new("/"));
        assert_eq!(h, "");
    }

    #[test]
    fn path_to_hash_no_leading_slash() {
        // Handles relative paths gracefully (though expected to receive absolute)
        let h = path_to_hash(Path::new("relative/path"));
        assert_eq!(h, "relative-path");
    }

    #[test]
    fn path_to_hash_truncation() {
        // Build a path that exceeds 200 chars after transformation
        // Each segment is "abcdefghij" (10 chars), separator becomes "-" (1 char).
        // We need the transformed name > 200 chars.
        // 20 segments of 10 chars = 200 chars of text + 19 dashes = 219 chars
        let segments: Vec<&str> = (0..20).map(|_| "abcdefghij").collect();
        let path_str = format!("/{}", segments.join("/"));
        let p = Path::new(&path_str);
        let h = path_to_hash(p);

        // Should be truncated at 200 + '-' + 8 hex chars = 209 chars
        assert_eq!(h.len(), 209);
        assert!(h[200..201].starts_with('-'));
        // Verify hex suffix is 8 chars of hex
        let suffix = &h[201..];
        assert_eq!(suffix.len(), 8);
        assert!(suffix.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn store_path_uses_state_dir() {
        let p = Path::new("/some/dir");
        let sp = store_path(p);
        assert!(sp.ends_with("some-dir"));
    }

    #[test]
    fn layer_path_format() {
        let store = Path::new("/tmp/test-store");
        let lp = layer_path(store, "myconfig", "local");
        assert_eq!(lp, PathBuf::from("/tmp/test-store/myconfig/local.yaml"));
    }

    #[test]
    fn active_path_format() {
        let store = Path::new("/tmp/test-store");
        let ap = active_path(store, "myconfig");
        assert_eq!(ap, PathBuf::from("/tmp/test-store/myconfig/.active"));
    }
}
