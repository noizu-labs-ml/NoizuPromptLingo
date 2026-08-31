use crate::config::AppConfig;
use crate::kinds::{InstallStatus, Kind, Provider, SourceItem};
use anyhow::{bail, Context, Result};
use chrono::Local;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub struct LinkAction {
    pub provider: Provider,
    pub kind: Kind,
    pub name: String,
    pub dest: PathBuf,
    #[allow(dead_code)]
    pub source: PathBuf,
    pub message: String,
    #[allow(dead_code)]
    pub changed: bool,
}

/// Classify install status of `dest` relative to expected source under cfg.
// ⟦𓃫𓊖𓂣𓆡⟧ classify :: Classify install status of `dest` relative to expected source under cfg.
pub fn classify(
    cfg: &AppConfig,
    kind: Kind,
    dest: &Path,
    expected_source: Option<&Path>,
) -> InstallStatus {
    if !dest.exists()
        && !dest
            .symlink_metadata()
            .map(|m| m.file_type().is_symlink())
            .unwrap_or(false)
    {
        // dangling symlink still "exists" via symlink_metadata
        if dest.symlink_metadata().is_ok() {
            // continue below
        } else {
            return InstallStatus::Disabled;
        }
    }

    let meta = match dest.symlink_metadata() {
        Ok(m) => m,
        Err(_) => return InstallStatus::Disabled,
    };

    if meta.file_type().is_symlink() {
        let target = match fs::read_link(dest) {
            Ok(t) => t,
            Err(_) => return InstallStatus::Broken,
        };
        // Resolve relative symlink targets against dest parent
        let resolved = if target.is_absolute() {
            target.clone()
        } else {
            dest.parent()
                .unwrap_or_else(|| Path::new("."))
                .join(&target)
        };
        if !resolved.exists() {
            return InstallStatus::Broken;
        }
        if let Some(exp) = expected_source {
            if same_path(&resolved, exp) {
                return InstallStatus::Enabled;
            }
        }
        if cfg.is_under_source(kind, &resolved) {
            // managed but maybe different source name? still enabled if under sources
            if expected_source.is_some() {
                return InstallStatus::Foreign;
            }
            return InstallStatus::Enabled;
        }
        return InstallStatus::Foreign;
    }

    // real file or directory
    if expected_source.is_none() {
        return InstallStatus::Real;
    }
    InstallStatus::Real
}

fn same_path(a: &Path, b: &Path) -> bool {
    if let (Ok(ca), Ok(cb)) = (a.canonicalize(), b.canonicalize()) {
        return ca == cb;
    }
    a == b
}

// ⟦𓉢𓏈𓆚𓉾⟧ enable_item :: auto-generated pointer for public function enable_item
pub fn enable_item(
    cfg: &AppConfig,
    provider: Provider,
    item: &SourceItem,
    replace: bool,
    dry_run: bool,
) -> Result<LinkAction> {
    let Some(kind_dir) = cfg.kind_dir(provider, item.kind) else {
        bail!("provider {provider} has no {} dir configured", item.kind);
    };
    // Never touch codex .system
    if kind_dir
        .file_name()
        .and_then(|n| n.to_str())
        .map(|n| n == ".system")
        .unwrap_or(false)
    {
        bail!("refusing to write under .system");
    }

    let dest = item.dest_path(&kind_dir);
    let source = item.path.clone();

    if !source.exists() {
        bail!("source missing: {}", source.display());
    }

    // Already correct?
    if dest
        .symlink_metadata()
        .map(|m| m.file_type().is_symlink())
        .unwrap_or(false)
    {
        if let Ok(target) = fs::read_link(&dest) {
            let resolved = if target.is_absolute() {
                target
            } else {
                dest.parent().unwrap_or(Path::new(".")).join(target)
            };
            if same_path(&resolved, &source) {
                return Ok(LinkAction {
                    provider,
                    kind: item.kind,
                    name: item.name.clone(),
                    dest,
                    source,
                    message: "already enabled".into(),
                    changed: false,
                });
            }
        }
    }

    if dest.exists() || dest.symlink_metadata().is_ok() {
        if !replace {
            let status = classify(cfg, item.kind, &dest, Some(&source));
            bail!(
                "{} exists at {} (status={status}); use --replace to backup and relink",
                item.kind.singular(),
                dest.display()
            );
        }
        if !dry_run {
            backup_path(&dest)?;
        }
    }

    if !dry_run {
        if let Some(parent) = dest.parent() {
            fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
        }
        // Remove leftover after backup if still present
        if dest.symlink_metadata().is_ok() {
            fs::remove_file(&dest).or_else(|_| fs::remove_dir_all(&dest))?;
        }
        std::os::unix::fs::symlink(&source, &dest)
            .with_context(|| format!("symlink {} -> {}", dest.display(), source.display()))?;
    }

    Ok(LinkAction {
        provider,
        kind: item.kind,
        name: item.name.clone(),
        dest,
        source,
        message: if dry_run {
            "would enable".into()
        } else {
            "enabled".into()
        },
        changed: true,
    })
}

// ⟦𓀝𓄰𓎵𓎃⟧ disable_item :: auto-generated pointer for public function disable_item
pub fn disable_item(
    cfg: &AppConfig,
    provider: Provider,
    kind: Kind,
    name: &str,
    source: Option<&SourceItem>,
    dry_run: bool,
) -> Result<LinkAction> {
    let Some(kind_dir) = cfg.kind_dir(provider, kind) else {
        bail!("provider {provider} has no {kind} dir configured");
    };
    let dest = match kind {
        Kind::Skills => kind_dir.join(name),
        Kind::Agents | Kind::Commands => kind_dir.join(format!("{name}.md")),
    };
    let source_path = source.map(|s| s.path.clone()).unwrap_or_default();

    if !dest.exists() && dest.symlink_metadata().is_err() {
        return Ok(LinkAction {
            provider,
            kind,
            name: name.to_string(),
            dest,
            source: source_path,
            message: "already disabled".into(),
            changed: false,
        });
    }

    let meta = dest
        .symlink_metadata()
        .with_context(|| format!("stat {}", dest.display()))?;
    if !meta.file_type().is_symlink() {
        bail!(
            "{} is a real path (not a managed symlink); refuse to remove: {}",
            kind.singular(),
            dest.display()
        );
    }
    let target = fs::read_link(&dest)?;
    let resolved = if target.is_absolute() {
        target
    } else {
        dest.parent().unwrap_or(Path::new(".")).join(target)
    };
    if !cfg.is_under_source(kind, &resolved) && !resolved.exists() {
        // broken managed? only remove if expected source matches or under source when resolved
        if let Some(s) = source {
            if !same_path(&resolved, &s.path) && resolved.exists() {
                bail!(
                    "symlink points outside sources: {} -> {}",
                    dest.display(),
                    resolved.display()
                );
            }
        } else if resolved.exists() {
            bail!(
                "symlink points outside sources: {} -> {}",
                dest.display(),
                resolved.display()
            );
        }
        // dangling under sources prefix or known source — allow
    } else if resolved.exists() && !cfg.is_under_source(kind, &resolved) {
        bail!(
            "symlink points outside sources: {} -> {}",
            dest.display(),
            resolved.display()
        );
    }

    if !dry_run {
        fs::remove_file(&dest).with_context(|| format!("remove {}", dest.display()))?;
    }

    Ok(LinkAction {
        provider,
        kind,
        name: name.to_string(),
        dest,
        source: source_path,
        message: if dry_run {
            "would disable".into()
        } else {
            "disabled".into()
        },
        changed: true,
    })
}

fn backup_path(path: &Path) -> Result<()> {
    let ts = Local::now().format("%Y%m%d%H%M%S");
    let bak = path.with_file_name(format!(
        "{}.bak.{}",
        path.file_name().and_then(|n| n.to_str()).unwrap_or("item"),
        ts
    ));
    fs::rename(path, &bak)
        .with_context(|| format!("backup {} -> {}", path.display(), bak.display()))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::SourceRoot;
    use std::io::Write;
    use tempfile::tempdir;

    fn test_cfg(src: &Path, prov: &Path) -> AppConfig {
        let mut cfg = AppConfig::builtin_defaults();
        cfg.sources.skills = vec![SourceRoot {
            path: src.to_path_buf(),
            priority: 10,
        }];
        cfg.providers.insert(
            "claude".into(),
            crate::config::ProviderDirs {
                skills_dir: Some(prov.join("skills")),
                agents_dir: Some(prov.join("agents")),
                commands_dir: Some(prov.join("commands")),
            },
        );
        cfg
    }

    #[test]
    fn enable_disable_skill() {
        let tmp = tempdir().unwrap();
        let src = tmp.path().join("repo");
        let skill = src.join("demo");
        fs::create_dir_all(&skill).unwrap();
        let mut f = fs::File::create(skill.join("SKILL.md")).unwrap();
        writeln!(f, "---\nname: demo\ndescription: d\n---\n").unwrap();

        let prov = tmp.path().join("claude");
        let cfg = test_cfg(&src, &prov);
        let item = SourceItem {
            kind: Kind::Skills,
            name: "demo".into(),
            path: skill.clone(),
            priority: 10,
            source_root: src.clone(),
            frontmatter_name: Some("demo".into()),
            title: None,
            description: Some("d".into()),
            frontmatter_bytes: 0,
            frontmatter_chars: 0,
            frontmatter_fields: 0,
        };

        let act = enable_item(&cfg, Provider::Claude, &item, false, false).unwrap();
        assert!(act.changed);
        assert!(prov.join("skills/demo").is_symlink());

        let act2 = enable_item(&cfg, Provider::Claude, &item, false, false).unwrap();
        assert!(!act2.changed);

        let dis = disable_item(
            &cfg,
            Provider::Claude,
            Kind::Skills,
            "demo",
            Some(&item),
            false,
        )
        .unwrap();
        assert!(dis.changed);
        assert!(!prov.join("skills/demo").exists());
    }

    #[test]
    fn refuse_real_without_replace() {
        let tmp = tempdir().unwrap();
        let src = tmp.path().join("repo");
        let skill = src.join("demo");
        fs::create_dir_all(&skill).unwrap();
        fs::write(
            skill.join("SKILL.md"),
            "---\nname: demo\ndescription: d\n---\n",
        )
        .unwrap();
        let prov = tmp.path().join("claude");
        fs::create_dir_all(prov.join("skills/demo")).unwrap();
        let cfg = test_cfg(&src, &prov);
        let item = SourceItem {
            kind: Kind::Skills,
            name: "demo".into(),
            path: skill,
            priority: 10,
            source_root: src,
            frontmatter_name: None,
            title: None,
            description: None,
            frontmatter_bytes: 0,
            frontmatter_chars: 0,
            frontmatter_fields: 0,
        };
        assert!(enable_item(&cfg, Provider::Claude, &item, false, false).is_err());
        let act = enable_item(&cfg, Provider::Claude, &item, true, false).unwrap();
        assert!(act.changed);
        assert!(prov.join("skills/demo").is_symlink());
    }
}
