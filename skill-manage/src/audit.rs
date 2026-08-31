use crate::catalog::Catalog;
use crate::config::AppConfig;
use crate::kinds::{InstallStatus, Kind, Provider, SourceItem};
use crate::link::classify;
use crate::sources::{discover, skill_structure_ok};
use anyhow::Result;
use serde::Serialize;
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize)]
pub struct AuditReport {
    pub items: Vec<AuditItem>,
    pub collisions: Vec<String>,
    pub catalog_errors: Vec<String>,
    pub catalog_warnings: Vec<String>,
    pub provider_warnings: Vec<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct AuditItem {
    pub kind: String,
    pub name: String,
    pub source: Option<String>,
    pub structure_ok: bool,
    pub structure_issues: Vec<String>,
    pub providers: BTreeMap<String, String>,
}

// ⟦𓃴𓆪𓄳𓊜⟧ run_audit :: auto-generated pointer for public function run_audit
pub fn run_audit(
    cfg: &AppConfig,
    catalog: &Catalog,
    kinds: &[Kind],
    providers: &[Provider],
) -> Result<AuditReport> {
    let mut items = Vec::new();
    let mut collisions = Vec::new();
    let mut known: BTreeMap<Kind, BTreeSet<String>> = BTreeMap::new();
    let mut provider_warnings = Vec::new();

    for kind in kinds {
        let (discovered, coll) = discover(cfg, *kind)?;
        known.insert(*kind, discovered.keys().cloned().collect());
        for (name, winner, loser) in coll {
            collisions.push(format!(
                "{kind}/{name}: {} wins over {}",
                winner.display(),
                loser.display()
            ));
        }

        for (name, item) in &discovered {
            let (structure_ok, structure_issues) = match kind {
                Kind::Skills => skill_structure_ok(&item.path),
                Kind::Agents | Kind::Commands => {
                    let (n, d) = crate::sources::parse_frontmatter_meta(&item.path);
                    let mut issues = Vec::new();
                    if n.is_none() {
                        issues.push("frontmatter missing name".into());
                    }
                    if d.is_none() {
                        issues.push("frontmatter missing description".into());
                    }
                    (issues.is_empty(), issues)
                }
            };

            let mut prov_map = BTreeMap::new();
            for provider in providers {
                let status = install_status(cfg, *provider, item);
                prov_map.insert(provider.as_str().to_string(), status.as_str().to_string());
            }

            items.push(AuditItem {
                kind: kind.as_str().to_string(),
                name: name.clone(),
                source: Some(item.path.display().to_string()),
                structure_ok,
                structure_issues,
                providers: prov_map,
            });
        }

        // Orphans in provider dirs
        for provider in providers {
            if let Some(dir) = cfg.kind_dir(*provider, *kind) {
                if *kind == Kind::Skills && dir.join("skills").is_dir() {
                    provider_warnings.push(format!(
                        "{provider}: nested skills tree at {} (unmanaged layout)",
                        dir.join("skills").display()
                    ));
                }
                if !dir.is_dir() {
                    continue;
                }
                for entry in fs::read_dir(&dir).into_iter().flatten().flatten() {
                    let path = entry.path();
                    let name = match kind {
                        Kind::Skills => {
                            if !path.is_dir() && !path.symlink_metadata().map(|m| m.file_type().is_symlink()).unwrap_or(false) {
                                continue;
                            }
                            let n = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
                            if n.starts_with('.') || n.ends_with(".bak") || n.contains(".bak.") {
                                continue;
                            }
                            n.to_string()
                        }
                        Kind::Agents | Kind::Commands => {
                            let n = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
                            if !n.ends_with(".md") || n.starts_with('.') {
                                continue;
                            }
                            n.trim_end_matches(".md").to_string()
                        }
                    };
                    if discovered.contains_key(&name) {
                        continue;
                    }
                    // skip backup names
                    if name.contains(".bak.") {
                        continue;
                    }
                    let status = classify(cfg, *kind, &path, None);
                    let mut prov_map = BTreeMap::new();
                    for p in providers {
                        if p == provider {
                            prov_map.insert(p.as_str().to_string(), status.as_str().to_string());
                        }
                    }
                    items.push(AuditItem {
                        kind: kind.as_str().to_string(),
                        name: format!("{name} (orphan)"),
                        source: None,
                        structure_ok: true,
                        structure_issues: vec!["present in provider dir but not in sources".into()],
                        providers: prov_map,
                    });
                }
            }
        }
    }

    let (catalog_errors, catalog_warnings) = catalog.validate(&known);

    Ok(AuditReport {
        items,
        collisions,
        catalog_errors,
        catalog_warnings,
        provider_warnings,
    })
}

fn install_status(cfg: &AppConfig, provider: Provider, item: &SourceItem) -> InstallStatus {
    let Some(kind_dir) = cfg.kind_dir(provider, item.kind) else {
        return InstallStatus::Disabled;
    };
    let dest = item.dest_path(&kind_dir);
    classify(cfg, item.kind, &dest, Some(&item.path))
}

// ⟦𓅻𓊍𓎮𓎫⟧ format_text :: auto-generated pointer for public function format_text
pub fn format_text(report: &AuditReport) -> String {
    let mut out = String::new();
    for item in &report.items {
        let struct_mark = if item.structure_ok { "ok" } else { "FAIL" };
        let provs: Vec<String> = item
            .providers
            .iter()
            .map(|(k, v)| format!("{k}={v}"))
            .collect();
        out.push_str(&format!(
            "{:<10} {:<32} struct={:<4} {}\n",
            item.kind,
            item.name,
            struct_mark,
            provs.join(" ")
        ));
        for issue in &item.structure_issues {
            out.push_str(&format!("    ! {issue}\n"));
        }
    }
    if !report.collisions.is_empty() {
        out.push_str("\n# Source collisions\n");
        for c in &report.collisions {
            out.push_str(&format!("  {c}\n"));
        }
    }
    if !report.provider_warnings.is_empty() {
        out.push_str("\n# Provider warnings\n");
        for w in &report.provider_warnings {
            out.push_str(&format!("  {w}\n"));
        }
    }
    if !report.catalog_errors.is_empty() {
        out.push_str("\n# Catalog errors\n");
        for e in &report.catalog_errors {
            out.push_str(&format!("  {e}\n"));
        }
    }
    if !report.catalog_warnings.is_empty() {
        out.push_str("\n# Catalog warnings\n");
        for w in &report.catalog_warnings {
            out.push_str(&format!("  {w}\n"));
        }
    }
    out
}

// ⟦𓐫𓉎𓌳𓍫⟧ has_strict_failures :: auto-generated pointer for public function has_strict_failures
pub fn has_strict_failures(report: &AuditReport) -> bool {
    if !report.catalog_errors.is_empty() {
        return true;
    }
    for item in &report.items {
        if !item.structure_ok {
            return true;
        }
        for status in item.providers.values() {
            if status == "broken" {
                return true;
            }
        }
    }
    false
}

// silence unused import if PathBuf not used in all builds
#[allow(dead_code)]
fn _pathbuf() -> PathBuf {
    PathBuf::new()
}
