use crate::config::{AppConfig, SourceRoot};
use crate::kinds::{Kind, SourceItem};
use anyhow::Result;
use serde_yaml::Value;
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

const SKILL_SKIP: &[&str] = &["shared", "evals"];

/// Discover all items of a kind from configured sources.
/// On name collision, lower priority wins; losers are recorded in `collisions`.
// ⟦𓂞𓈈𓁨𓎯⟧ discover :: Discover all items of a kind from configured sources.
pub fn discover(
    cfg: &AppConfig,
    kind: Kind,
) -> Result<(
    BTreeMap<String, SourceItem>,
    Vec<(String, PathBuf, PathBuf)>,
)> {
    let mut roots: Vec<&SourceRoot> = cfg.source_roots(kind).iter().collect();
    roots.sort_by_key(|r| r.priority);

    let mut items: BTreeMap<String, SourceItem> = BTreeMap::new();
    let mut collisions: Vec<(String, PathBuf, PathBuf)> = Vec::new();

    for root in roots {
        if !root.path.is_dir() {
            continue;
        }
        let found = match kind {
            Kind::Skills => scan_skills(&root.path, root.priority)?,
            Kind::Agents | Kind::Commands => scan_md_files(kind, &root.path, root.priority)?,
        };
        for item in found {
            if let Some(existing) = items.get(&item.name) {
                collisions.push((item.name.clone(), existing.path.clone(), item.path.clone()));
            } else {
                items.insert(item.name.clone(), item);
            }
        }
    }
    Ok((items, collisions))
}

fn scan_skills(root: &Path, priority: i32) -> Result<Vec<SourceItem>> {
    let mut out = Vec::new();
    let entries = match fs::read_dir(root) {
        Ok(e) => e,
        Err(_) => return Ok(out),
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }
        let name = match path.file_name().and_then(|n| n.to_str()) {
            Some(n) if !n.starts_with('.') && !SKILL_SKIP.contains(&n) => n.to_string(),
            _ => continue,
        };
        let skill_md = path.join("SKILL.md");
        if !skill_md.is_file() {
            continue;
        }
        let meta = parse_frontmatter(&skill_md);
        out.push(SourceItem {
            kind: Kind::Skills,
            name,
            path,
            priority,
            source_root: root.to_path_buf(),
            frontmatter_name: meta.name,
            title: meta.title,
            description: meta.description,
            frontmatter_bytes: meta.raw_bytes,
            frontmatter_chars: meta.raw_chars,
            frontmatter_fields: meta.field_count,
        });
    }
    Ok(out)
}

fn scan_md_files(kind: Kind, root: &Path, priority: i32) -> Result<Vec<SourceItem>> {
    let mut out = Vec::new();
    let entries = match fs::read_dir(root) {
        Ok(e) => e,
        Err(_) => return Ok(out),
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_file() {
            continue;
        }
        let fname = match path.file_name().and_then(|n| n.to_str()) {
            Some(n) if n.ends_with(".md") && !n.starts_with('.') => n,
            _ => continue,
        };
        let name = fname.trim_end_matches(".md").to_string();
        let meta = parse_frontmatter(&path);
        out.push(SourceItem {
            kind,
            name,
            path,
            priority,
            source_root: root.to_path_buf(),
            frontmatter_name: meta.name,
            title: meta.title,
            description: meta.description,
            frontmatter_bytes: meta.raw_bytes,
            frontmatter_chars: meta.raw_chars,
            frontmatter_fields: meta.field_count,
        });
    }
    Ok(out)
}

#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct FrontmatterMeta {
    pub name: Option<String>,
    pub title: Option<String>,
    pub description: Option<String>,
    pub raw_bytes: usize,
    pub raw_chars: usize,
    pub field_count: usize,
}

/// Parse YAML frontmatter and retain the exact delimited section size.
// ⟦𓊞𓎦𓇱𓌰⟧ parse_frontmatter :: Parse YAML frontmatter and retain the exact delimited section size.
pub fn parse_frontmatter(path: &Path) -> FrontmatterMeta {
    let Ok(text) = fs::read_to_string(path) else {
        return FrontmatterMeta::default();
    };
    parse_frontmatter_text(&text)
}

fn parse_frontmatter_text(text: &str) -> FrontmatterMeta {
    let Some((yaml, raw)) = extract_frontmatter(text) else {
        return FrontmatterMeta::default();
    };
    let value: Value = match serde_yaml::from_str(yaml) {
        Ok(value) => value,
        Err(_) => Value::Null,
    };
    let mapping = value.as_mapping();
    FrontmatterMeta {
        name: mapping.and_then(|m| string_field(m, "name")),
        title: mapping.and_then(|m| string_field(m, "title")),
        description: mapping.and_then(|m| string_field(m, "description")),
        raw_bytes: raw.len(),
        raw_chars: raw.chars().count(),
        field_count: mapping.map_or(0, serde_yaml::Mapping::len),
    }
}

fn extract_frontmatter(text: &str) -> Option<(&str, &str)> {
    let first_end = text.find('\n')? + 1;
    if text[..first_end].trim_end_matches(['\r', '\n']) != "---" {
        return None;
    }

    let mut offset = first_end;
    for line in text[first_end..].split_inclusive('\n') {
        let next = offset + line.len();
        if line.trim_end_matches(['\r', '\n']) == "---" {
            return Some((&text[first_end..offset], &text[..next]));
        }
        offset = next;
    }
    None
}

fn string_field(mapping: &serde_yaml::Mapping, key: &str) -> Option<String> {
    mapping
        .get(Value::String(key.to_string()))
        .and_then(Value::as_str)
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(ToOwned::to_owned)
}

/// Parse YAML frontmatter for `name` and `description`.
// ⟦𓄬𓍜𓎗𓎚⟧ parse_frontmatter_meta :: Parse YAML frontmatter for `name` and `description`.
pub fn parse_frontmatter_meta(path: &Path) -> (Option<String>, Option<String>) {
    let meta = parse_frontmatter(path);
    (meta.name, meta.description)
}

/// Check skill structure: SKILL.md exists with name + description in frontmatter.
// ⟦𓄧𓈀𓇉𓂢⟧ skill_structure_ok :: Check skill structure: SKILL.md exists with name + description in frontmatter.
pub fn skill_structure_ok(path: &Path) -> (bool, Vec<String>) {
    let mut issues = Vec::new();
    let skill_md = if path.is_dir() {
        path.join("SKILL.md")
    } else {
        path.to_path_buf()
    };
    if !skill_md.is_file() {
        issues.push("missing SKILL.md".into());
        return (false, issues);
    }
    let (name, desc) = parse_frontmatter_meta(&skill_md);
    if name.is_none() {
        issues.push("SKILL.md frontmatter missing name".into());
    }
    if desc.is_none() {
        issues.push("SKILL.md frontmatter missing description".into());
    }
    (issues.is_empty(), issues)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::tempdir;

    #[test]
    fn discover_skills() {
        let dir = tempdir().unwrap();
        let skill = dir.path().join("demo");
        fs::create_dir(&skill).unwrap();
        let mut f = fs::File::create(skill.join("SKILL.md")).unwrap();
        writeln!(f, "---\nname: demo\ndescription: hi\n---\n").unwrap();
        fs::create_dir(dir.path().join("shared")).unwrap();

        let mut cfg = AppConfig::builtin_defaults();
        cfg.sources.skills = vec![crate::config::SourceRoot {
            path: dir.path().to_path_buf(),
            priority: 10,
        }];
        let (items, _) = discover(&cfg, Kind::Skills).unwrap();
        assert!(items.contains_key("demo"));
        assert!(!items.contains_key("shared"));
    }

    #[test]
    fn discover_agents() {
        let dir = tempdir().unwrap();
        let mut f = fs::File::create(dir.path().join("npl-tasker.md")).unwrap();
        writeln!(f, "---\nname: npl-tasker\ndescription: t\n---\n").unwrap();

        let mut cfg = AppConfig::builtin_defaults();
        cfg.sources.agents = vec![crate::config::SourceRoot {
            path: dir.path().to_path_buf(),
            priority: 10,
        }];
        let (items, _) = discover(&cfg, Kind::Agents).unwrap();
        assert!(items.contains_key("npl-tasker"));
    }

    #[test]
    fn parses_multiline_frontmatter_and_exact_size() {
        let text = "---\nname: demo\ntitle: Demo Skill\ndescription: >-\n  Does useful work\n  across lines.\nrunners:\n  - codex\n---\n# Body\n";
        let meta = parse_frontmatter_text(text);
        let raw = text.split("# Body").next().unwrap();

        assert_eq!(meta.name.as_deref(), Some("demo"));
        assert_eq!(meta.title.as_deref(), Some("Demo Skill"));
        assert_eq!(
            meta.description.as_deref(),
            Some("Does useful work across lines.")
        );
        assert_eq!(meta.field_count, 4);
        assert_eq!(meta.raw_bytes, raw.len());
        assert_eq!(meta.raw_chars, raw.chars().count());
    }
}
