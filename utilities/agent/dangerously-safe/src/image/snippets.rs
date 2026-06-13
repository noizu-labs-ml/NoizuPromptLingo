//! Per-app Dockerfile snippet library.
//!
//! Each snippet is a file `apps/<slug>.dockerfile` whose leading comment block is
//! parsed as simple front-matter:
//!
//! ```dockerfile
//! # requires: base
//! # apt: git, build-essential
//! RUN ...install...
//! ```
//!
//! Snippets are discovered across [`crate::paths::snippet_dirs`] (user config dir
//! wins over shared data dir). For development, a `snippets/` dir next to the
//! binary's manifest is also searched so the tool works from a source checkout.

use crate::error::{Result, SandboxError};
use crate::paths;
use anyhow::Context;
use std::collections::BTreeMap;
use std::path::PathBuf;

/// A single app install fragment.
#[derive(Debug, Clone)]
pub struct Snippet {
    /// The slug this snippet installs (matches its file name and map key).
    #[allow(dead_code)]
    pub slug: String,
    pub requires: Vec<String>,
    pub apt: Vec<String>,
    /// The Dockerfile body with the front-matter comments stripped.
    pub body: String,
}

/// The base image fragment used when building from scratch.
#[derive(Debug, Clone)]
pub struct BaseImage {
    pub apt: Vec<String>,
    pub body: String,
}

#[derive(Debug, Clone)]
pub struct SnippetLibrary {
    snippets: BTreeMap<String, Snippet>,
    base: BaseImage,
}

impl SnippetLibrary {
    /// Load all snippets from the search path. The first directory containing a
    /// `base.dockerfile` provides the base; per-app snippets from all directories
    /// are merged with earlier (higher priority) dirs winning.
    pub fn load() -> Result<Self> {
        let mut snippets: BTreeMap<String, Snippet> = BTreeMap::new();
        let mut base: Option<BaseImage> = None;

        for dir in search_dirs() {
            if !dir.exists() {
                continue;
            }
            // base.dockerfile (first one found wins)
            let base_path = dir.join("base.dockerfile");
            if base.is_none() && base_path.exists() {
                let raw = std::fs::read_to_string(&base_path)
                    .with_context(|| format!("reading {}", base_path.display()))?;
                let fm = parse_front_matter(&raw);
                base = Some(BaseImage {
                    apt: fm.apt,
                    body: fm.body,
                });
            }
            // apps/*.dockerfile
            let apps_dir = dir.join("apps");
            if apps_dir.exists() {
                for entry in std::fs::read_dir(&apps_dir)
                    .with_context(|| format!("listing {}", apps_dir.display()))?
                {
                    let entry = entry?;
                    let path = entry.path();
                    let Some(slug) = path
                        .file_stem()
                        .and_then(|s| s.to_str())
                        .filter(|_| path.extension().and_then(|e| e.to_str()) == Some("dockerfile"))
                    else {
                        continue;
                    };
                    // earlier dirs win
                    if snippets.contains_key(slug) {
                        continue;
                    }
                    let raw = std::fs::read_to_string(&path)
                        .with_context(|| format!("reading {}", path.display()))?;
                    let fm = parse_front_matter(&raw);
                    snippets.insert(
                        slug.to_string(),
                        Snippet {
                            slug: slug.to_string(),
                            requires: fm.requires,
                            apt: fm.apt,
                            body: fm.body,
                        },
                    );
                }
            }
        }

        let base = base.unwrap_or_else(BaseImage::fallback);
        Ok(Self { snippets, base })
    }

    pub fn base(&self) -> &BaseImage {
        &self.base
    }

    pub fn get(&self, slug: &str) -> Result<&Snippet> {
        self.snippets
            .get(slug)
            .ok_or_else(|| SandboxError::UnknownSnippet(slug.to_string()).into())
    }

    pub fn available(&self) -> impl Iterator<Item = &str> {
        self.snippets.keys().map(|s| s.as_str())
    }

    #[cfg(test)]
    pub fn from_parts(snippets: Vec<Snippet>, base: BaseImage) -> Self {
        Self {
            snippets: snippets.into_iter().map(|s| (s.slug.clone(), s)).collect(),
            base,
        }
    }
}

impl BaseImage {
    fn fallback() -> Self {
        Self {
            apt: vec!["ca-certificates".into(), "curl".into(), "git".into()],
            body: "FROM debian:stable-slim".to_string(),
        }
    }
}

/// Directories to search for snippets, highest priority first. The dev `snippets/`
/// dir alongside the crate manifest is appended as a fallback.
fn search_dirs() -> Vec<PathBuf> {
    let mut dirs = paths::snippet_dirs();
    dirs.push(PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("snippets"));
    dirs
}

struct FrontMatter {
    requires: Vec<String>,
    apt: Vec<String>,
    body: String,
}

/// Parse leading `# key: a, b` comment lines as front-matter; everything else is
/// the body. Front-matter only counts while we're still in the leading comment
/// block (the first non-comment, non-blank line ends it).
fn parse_front_matter(raw: &str) -> FrontMatter {
    let mut requires = Vec::new();
    let mut apt = Vec::new();
    let mut body_lines = Vec::new();
    let mut in_header = true;

    for line in raw.lines() {
        let trimmed = line.trim();
        if in_header && trimmed.starts_with('#') {
            let content = trimmed.trim_start_matches('#').trim();
            if let Some((key, val)) = content.split_once(':') {
                let items: Vec<String> = val
                    .split(',')
                    .map(|s| s.trim().to_string())
                    .filter(|s| !s.is_empty())
                    .collect();
                match key.trim() {
                    "requires" => requires.extend(items),
                    "apt" => apt.extend(items),
                    _ => {}
                }
            }
            continue;
        }
        if in_header && trimmed.is_empty() {
            // skip blank lines inside the header block
            continue;
        }
        in_header = false;
        body_lines.push(line);
    }

    FrontMatter {
        requires,
        apt,
        body: body_lines.join("\n").trim().to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_front_matter() {
        let raw = "# requires: base\n# apt: git, curl\nRUN echo hi\nRUN echo bye\n";
        let fm = parse_front_matter(raw);
        assert_eq!(fm.requires, vec!["base"]);
        assert_eq!(fm.apt, vec!["git", "curl"]);
        assert_eq!(fm.body, "RUN echo hi\nRUN echo bye");
    }

    #[test]
    fn comment_after_body_is_not_front_matter() {
        let raw = "RUN echo hi\n# apt: should-not-count\n";
        let fm = parse_front_matter(raw);
        assert!(fm.apt.is_empty());
        assert!(fm.body.contains("should-not-count"));
    }

    fn test_lib() -> SnippetLibrary {
        SnippetLibrary::from_parts(
            vec![Snippet {
                slug: "node".into(),
                requires: vec!["base".into()],
                apt: vec!["nodejs".into()],
                body: "RUN install node".into(),
            }],
            BaseImage {
                apt: vec!["git".into(), "curl".into()],
                body: "FROM debian:slim".into(),
            },
        )
    }

    #[test]
    fn get_known_snippet() {
        let lib = test_lib();
        let s = lib.get("node").unwrap();
        assert_eq!(s.apt, vec!["nodejs"]);
        assert!(s.requires.contains(&"base".to_string()));
    }

    #[test]
    fn get_unknown_snippet_errors() {
        assert!(test_lib().get("python").is_err());
    }

    #[test]
    fn available_lists_slugs() {
        let lib = test_lib();
        let avail: Vec<&str> = lib.available().collect();
        assert!(avail.contains(&"node"));
    }

    #[test]
    fn base_is_accessible() {
        let lib = test_lib();
        assert!(lib.base().body.contains("FROM"));
    }

    #[test]
    fn base_image_fallback_is_valid() {
        let b = BaseImage::fallback();
        assert!(b.body.starts_with("FROM"));
        assert!(b.apt.contains(&"git".to_string()));
    }
}
