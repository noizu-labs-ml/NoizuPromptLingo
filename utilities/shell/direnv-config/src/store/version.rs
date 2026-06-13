use std::path::Path;
use anyhow::{Context, Result};

const VERSION_FILE: &str = ".version";

/// Read the current version from the store's .version file.
/// Returns 0 if the file does not exist or cannot be parsed.
pub fn read_version(store: &Path) -> u64 {
    let path = store.join(VERSION_FILE);
    match std::fs::read_to_string(&path) {
        Ok(contents) => contents.trim().parse::<u64>().unwrap_or(0),
        Err(_) => 0,
    }
}

/// Atomically increment the store version.
///
/// Reads the current version, increments it, writes it back.
/// Returns the new version number.
pub fn bump_version(store: &Path) -> Result<u64> {
    let path = store.join(VERSION_FILE);
    let current = read_version(store);
    let next = current + 1;

    // Write to a temporary file then rename for atomicity
    let tmp_path = store.join(".version.tmp");
    std::fs::write(&tmp_path, next.to_string())
        .with_context(|| format!("failed to write temporary version file: {}", tmp_path.display()))?;
    std::fs::rename(&tmp_path, &path)
        .with_context(|| format!("failed to rename version file: {} -> {}", tmp_path.display(), path.display()))?;

    Ok(next)
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn read_version_missing_file() {
        let tmp = TempDir::new().unwrap();
        assert_eq!(read_version(tmp.path()), 0);
    }

    #[test]
    fn read_version_existing_file() {
        let tmp = TempDir::new().unwrap();
        std::fs::write(tmp.path().join(".version"), "42").unwrap();
        assert_eq!(read_version(tmp.path()), 42);
    }

    #[test]
    fn read_version_corrupt_file() {
        let tmp = TempDir::new().unwrap();
        std::fs::write(tmp.path().join(".version"), "not-a-number").unwrap();
        assert_eq!(read_version(tmp.path()), 0);
    }

    #[test]
    fn bump_version_from_zero() {
        let tmp = TempDir::new().unwrap();
        let v = bump_version(tmp.path()).unwrap();
        assert_eq!(v, 1);
        assert_eq!(read_version(tmp.path()), 1);
    }

    #[test]
    fn bump_version_increments() {
        let tmp = TempDir::new().unwrap();
        std::fs::write(tmp.path().join(".version"), "10").unwrap();
        let v = bump_version(tmp.path()).unwrap();
        assert_eq!(v, 11);
        assert_eq!(read_version(tmp.path()), 11);
    }

    #[test]
    fn bump_version_sequential() {
        let tmp = TempDir::new().unwrap();
        bump_version(tmp.path()).unwrap();
        bump_version(tmp.path()).unwrap();
        let v = bump_version(tmp.path()).unwrap();
        assert_eq!(v, 3);
    }
}
