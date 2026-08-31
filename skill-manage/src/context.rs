use crate::config::AppConfig;
use crate::kinds::{InstallStatus, Kind, Provider, SourceItem};
use crate::link::classify;
use crate::sources::{discover, parse_frontmatter};
use anyhow::Result;
use clap::ValueEnum;
use serde::Serialize;
use std::path::{Path, PathBuf};

const APPROX_CHARS_PER_TOKEN: usize = 4;
const CODEX_FALLBACK_SKILL_METADATA_CHARS: usize = 8_000;
const CODEX_SKILL_CONTEXT_PERCENT: usize = 2;
const CODEX_MAX_DESCRIPTION_CHARS: usize = 1_024;
const NEAR_LIMIT_PERCENT: f64 = 80.0;

#[derive(Debug, Clone, Copy, PartialEq, Eq, ValueEnum)]
pub enum ContextSelection {
    /// Items present in provider directories, including managed, real, and foreign entries.
    Active,
    /// Managed symlinks only.
    Enabled,
    /// Every discovered source item, including disabled items.
    All,
}

#[derive(Debug, Clone, Serialize)]
pub struct ContextItemReport {
    pub provider: Provider,
    pub kind: Kind,
    pub name: String,
    pub status: InstallStatus,
    pub metadata_path: PathBuf,
    pub frontmatter_bytes: usize,
    pub frontmatter_chars: usize,
    pub frontmatter_fields: usize,
    pub name_chars: usize,
    pub title_chars: usize,
    pub description_chars: usize,
    pub estimated_tokens: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub codex_rendered_chars: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub codex_estimated_tokens: Option<usize>,
}

#[derive(Debug, Clone, Serialize)]
pub struct ContextBudgetReport {
    pub provider: Provider,
    pub scope: String,
    pub limit: usize,
    pub used: usize,
    pub unit: String,
    pub percent: f64,
    pub state: String,
    pub basis: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct ProviderContextReport {
    pub provider: Provider,
    pub selection: String,
    pub scope_note: String,
    pub item_count: usize,
    pub frontmatter_bytes: usize,
    pub frontmatter_chars: usize,
    pub estimated_tokens: usize,
    pub items: Vec<ContextItemReport>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub frontmatter_budget: Option<ContextBudgetReport>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub codex_skill_budget: Option<ContextBudgetReport>,
}

// ⟦𓃄𓅫𓋑𓉶⟧ build_reports :: auto-generated pointer for public function build_reports
pub fn build_reports(
    cfg: &AppConfig,
    kinds: &[Kind],
    providers: &[Provider],
    selection: ContextSelection,
    context_window: Option<usize>,
    frontmatter_limit_bytes: Option<usize>,
) -> Result<Vec<ProviderContextReport>> {
    let mut reports = Vec::new();
    for provider in providers {
        let mut items = Vec::new();
        for kind in kinds {
            let (discovered, _) = discover(cfg, *kind)?;
            for item in discovered.values() {
                let status = status_for(cfg, *provider, item);
                if !selection.includes(status) {
                    continue;
                }
                items.push(report_item(cfg, *provider, item, status));
            }
        }
        items.sort_by(|a, b| a.kind.cmp(&b.kind).then_with(|| a.name.cmp(&b.name)));
        reports.push(summarize_provider(
            *provider,
            selection,
            items,
            context_window,
            frontmatter_limit_bytes,
        ));
    }
    Ok(reports)
}

// ⟦𓊈𓂢𓍱𓃱⟧ format_text :: auto-generated pointer for public function format_text
pub fn format_text(reports: &[ProviderContextReport]) -> String {
    let mut out = String::new();
    for (index, report) in reports.iter().enumerate() {
        if index > 0 {
            out.push('\n');
        }
        out.push_str(&format!(
            "provider={} selection={}\n",
            report.provider, report.selection
        ));
        out.push_str(&format!(
            "{:<10} {:<28} {:<12} {:>9} {:>9} {:>9} {:>9}\n",
            "KIND", "NAME", "STATUS", "FM BYTES", "FM CHARS", "~TOKENS", "CODEX"
        ));
        for item in &report.items {
            let codex = item
                .codex_rendered_chars
                .map(|chars| format!("{chars}c"))
                .unwrap_or_else(|| "-".to_string());
            out.push_str(&format!(
                "{:<10} {:<28} {:<12} {:>9} {:>9} {:>9} {:>9}\n",
                item.kind,
                item.name,
                item.status,
                item.frontmatter_bytes,
                item.frontmatter_chars,
                item.estimated_tokens,
                codex
            ));
        }
        out.push_str(&format!(
            "total: {} items · {} bytes · {} chars · ~{} tokens\n",
            report.item_count,
            report.frontmatter_bytes,
            report.frontmatter_chars,
            report.estimated_tokens
        ));
        if let Some(budget) = &report.frontmatter_budget {
            out.push_str(&format!(
                "frontmatter cap: {} / {} bytes ({:.1}%) [{}]\n",
                budget.used, budget.limit, budget.percent, budget.state
            ));
        }
        if let Some(budget) = &report.codex_skill_budget {
            out.push_str(&format!(
                "codex skill metadata: {} / {} {} ({:.1}%) [{}]\n",
                budget.used, budget.limit, budget.unit, budget.percent, budget.state
            ));
            out.push_str(&format!("basis: {}\n", budget.basis));
        }
        out.push_str(&format!("scope: {}\n", report.scope_note));
    }
    out
}

// ⟦𓇐𓌝𓋵𓌄⟧ active_frontmatter_totals :: auto-generated pointer for public function active_frontmatter_totals
pub fn active_frontmatter_totals(rows: &[(InstallStatus, &SourceItem)]) -> (usize, usize) {
    rows.iter()
        .filter(|(status, _)| ContextSelection::Active.includes(*status))
        .fold((0, 0), |(bytes, chars), (_, item)| {
            (
                bytes.saturating_add(item.frontmatter_bytes),
                chars.saturating_add(item.frontmatter_chars),
            )
        })
}

// ⟦𓈦𓎇𓏁𓐊⟧ is_active_status :: auto-generated pointer for public function is_active_status
pub fn is_active_status(status: InstallStatus) -> bool {
    ContextSelection::Active.includes(status)
}

// ⟦𓇊𓀀𓀉𓁼⟧ codex_fallback_skill_budget_chars :: auto-generated pointer for public function codex_fallback_skill_budget_chars
pub fn codex_fallback_skill_budget_chars() -> usize {
    CODEX_FALLBACK_SKILL_METADATA_CHARS
}

// ⟦𓋶𓆄𓅩𓄥⟧ codex_item_rendered_chars :: auto-generated pointer for public function codex_item_rendered_chars
pub fn codex_item_rendered_chars(item: &SourceItem) -> usize {
    codex_rendered_chars(
        item.frontmatter_name.as_deref().unwrap_or(&item.name),
        item.description.as_deref().unwrap_or(""),
        &metadata_path(&item.path, item.kind),
    )
}

impl ContextSelection {
    fn includes(self, status: InstallStatus) -> bool {
        match self {
            ContextSelection::Active => matches!(
                status,
                InstallStatus::Enabled | InstallStatus::Real | InstallStatus::Foreign
            ),
            ContextSelection::Enabled => status == InstallStatus::Enabled,
            ContextSelection::All => true,
        }
    }

    fn as_str(self) -> &'static str {
        match self {
            ContextSelection::Active => "active",
            ContextSelection::Enabled => "enabled",
            ContextSelection::All => "all",
        }
    }
}

fn report_item(
    cfg: &AppConfig,
    provider: Provider,
    item: &SourceItem,
    status: InstallStatus,
) -> ContextItemReport {
    let source_metadata_path = metadata_path(&item.path, item.kind);
    let installed_metadata_path = cfg
        .kind_dir(provider, item.kind)
        .map(|dir| metadata_path(&item.dest_path(&dir), item.kind));
    let metadata_path = if ContextSelection::Active.includes(status) {
        installed_metadata_path
            .filter(|path| path.exists())
            .unwrap_or(source_metadata_path)
    } else {
        source_metadata_path
    };
    let meta = parse_frontmatter(&metadata_path);
    let display_name = meta.name.as_deref().unwrap_or(&item.name);
    let description = meta.description.as_deref().unwrap_or("");
    let codex_rendered_chars = (provider == Provider::Codex && item.kind == Kind::Skills)
        .then(|| codex_rendered_chars(display_name, description, &metadata_path));

    ContextItemReport {
        provider,
        kind: item.kind,
        name: item.name.clone(),
        status,
        metadata_path,
        frontmatter_bytes: meta.raw_bytes,
        frontmatter_chars: meta.raw_chars,
        frontmatter_fields: meta.field_count,
        name_chars: char_count(meta.name.as_deref()),
        title_chars: char_count(meta.title.as_deref()),
        description_chars: char_count(meta.description.as_deref()),
        estimated_tokens: estimate_tokens(meta.raw_chars),
        codex_rendered_chars,
        codex_estimated_tokens: codex_rendered_chars.map(estimate_tokens),
    }
}

fn summarize_provider(
    provider: Provider,
    selection: ContextSelection,
    items: Vec<ContextItemReport>,
    context_window: Option<usize>,
    frontmatter_limit_bytes: Option<usize>,
) -> ProviderContextReport {
    let frontmatter_bytes = items.iter().map(|item| item.frontmatter_bytes).sum();
    let frontmatter_chars = items.iter().map(|item| item.frontmatter_chars).sum();
    let estimated_tokens = estimate_tokens(frontmatter_chars);
    let frontmatter_budget = frontmatter_limit_bytes.map(|limit| {
        budget_report(
            provider,
            frontmatter_bytes,
            limit,
            "bytes",
            "User-supplied raw YAML frontmatter cap".to_string(),
            "frontmatter",
        )
    });
    let codex_skill_budget = (provider == Provider::Codex).then(|| {
        let rendered_chars: usize = items
            .iter()
            .filter_map(|item| item.codex_rendered_chars)
            .sum();
        match context_window.filter(|window| *window > 0) {
            Some(window) => {
                let limit = window
                    .saturating_mul(CODEX_SKILL_CONTEXT_PERCENT)
                    .saturating_div(100)
                    .max(1);
                budget_report(
                    provider,
                    estimate_tokens(rendered_chars),
                    limit,
                    "estimated tokens",
                    format!(
                        "Codex uses {}% of the model context window; rendered paths are conservative and token count is estimated at {} chars/token",
                        CODEX_SKILL_CONTEXT_PERCENT, APPROX_CHARS_PER_TOKEN
                    ),
                    "skills",
                )
            }
            None => budget_report(
                provider,
                rendered_chars,
                CODEX_FALLBACK_SKILL_METADATA_CHARS,
                "characters",
                "Codex fallback when model context size is unavailable; pass --context-window for the 2% token budget".to_string(),
                "skills",
            ),
        }
    });

    ProviderContextReport {
        provider,
        selection: selection.as_str().to_string(),
        scope_note: "Discovered items from configured source roots only; provider built-ins, plugins, and untracked runtime entries are excluded".to_string(),
        item_count: items.len(),
        frontmatter_bytes,
        frontmatter_chars,
        estimated_tokens,
        items,
        frontmatter_budget,
        codex_skill_budget,
    }
}

fn budget_report(
    provider: Provider,
    used: usize,
    limit: usize,
    unit: &str,
    basis: String,
    scope: &str,
) -> ContextBudgetReport {
    let percent = if limit == 0 {
        100.0
    } else {
        used as f64 * 100.0 / limit as f64
    };
    let state = if used > limit {
        "EXCEEDED"
    } else if percent >= NEAR_LIMIT_PERCENT {
        "NEAR LIMIT"
    } else {
        "ok"
    };
    ContextBudgetReport {
        provider,
        scope: scope.to_string(),
        limit,
        used,
        unit: unit.to_string(),
        percent,
        state: state.to_string(),
        basis,
    }
}

fn codex_rendered_chars(name: &str, description: &str, path: &Path) -> usize {
    let description = truncate_chars(description, CODEX_MAX_DESCRIPTION_CHARS);
    let line = if description.is_empty() {
        format!("- {name}: (file: {})", path.display())
    } else {
        format!("- {name}: {description} (file: {})", path.display())
    };
    line.chars().count()
}

fn truncate_chars(value: &str, max_chars: usize) -> String {
    if value.chars().count() <= max_chars {
        return value.to_string();
    }
    let keep = max_chars.saturating_sub(3);
    format!("{}...", value.chars().take(keep).collect::<String>())
}

fn char_count(value: Option<&str>) -> usize {
    value.map_or(0, |value| value.chars().count())
}

fn estimate_tokens(chars: usize) -> usize {
    chars.saturating_add(APPROX_CHARS_PER_TOKEN - 1) / APPROX_CHARS_PER_TOKEN
}

fn metadata_path(path: &Path, kind: Kind) -> PathBuf {
    match kind {
        Kind::Skills => path.join("SKILL.md"),
        Kind::Agents | Kind::Commands => path.to_path_buf(),
    }
}

fn status_for(cfg: &AppConfig, provider: Provider, item: &SourceItem) -> InstallStatus {
    let Some(kind_dir) = cfg.kind_dir(provider, item.kind) else {
        return InstallStatus::Disabled;
    };
    let dest = item.dest_path(&kind_dir);
    classify(cfg, item.kind, &dest, Some(&item.path))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::{ProviderDirs, SourceRoot};
    use std::fs;
    use std::os::unix::fs::symlink;
    use tempfile::tempdir;

    #[test]
    fn codex_description_is_capped_at_1024_chars() {
        let path = Path::new("/tmp/demo/SKILL.md");
        let long = "x".repeat(CODEX_MAX_DESCRIPTION_CHARS + 100);
        let rendered = codex_rendered_chars("demo", &long, path);
        let expected = format!(
            "- demo: {} (file: {})",
            "x".repeat(1021) + "...",
            path.display()
        );
        assert_eq!(rendered, expected.chars().count());
    }

    #[test]
    fn budget_warns_near_and_over_limit() {
        assert_eq!(
            budget_report(
                Provider::Codex,
                80,
                100,
                "characters",
                "test".into(),
                "skills"
            )
            .state,
            "NEAR LIMIT"
        );
        assert_eq!(
            budget_report(
                Provider::Codex,
                101,
                100,
                "characters",
                "test".into(),
                "skills"
            )
            .state,
            "EXCEEDED"
        );
    }

    #[test]
    fn active_selection_counts_runner_visible_states() {
        assert!(ContextSelection::Active.includes(InstallStatus::Enabled));
        assert!(ContextSelection::Active.includes(InstallStatus::Real));
        assert!(ContextSelection::Active.includes(InstallStatus::Foreign));
        assert!(!ContextSelection::Active.includes(InstallStatus::Disabled));
        assert!(!ContextSelection::Active.includes(InstallStatus::Broken));
    }

    #[test]
    fn reports_only_active_provider_selections() {
        let tmp = tempdir().unwrap();
        let source_root = tmp.path().join("sources");
        let enabled = source_root.join("enabled-skill");
        let disabled = source_root.join("disabled-skill");
        fs::create_dir_all(&enabled).unwrap();
        fs::create_dir_all(&disabled).unwrap();
        fs::write(
            enabled.join("SKILL.md"),
            "---\nname: enabled-skill\ndescription: Loaded by Codex\n---\n",
        )
        .unwrap();
        fs::write(
            disabled.join("SKILL.md"),
            "---\nname: disabled-skill\ndescription: Not loaded\n---\n",
        )
        .unwrap();

        let provider_root = tmp.path().join("codex-skills");
        fs::create_dir_all(&provider_root).unwrap();
        symlink(&enabled, provider_root.join("enabled-skill")).unwrap();

        let mut cfg = AppConfig::builtin_defaults();
        cfg.sources.skills = vec![SourceRoot {
            path: source_root,
            priority: 10,
        }];
        cfg.providers.insert(
            "codex".into(),
            ProviderDirs {
                skills_dir: Some(provider_root),
                agents_dir: None,
                commands_dir: None,
            },
        );

        let reports = build_reports(
            &cfg,
            &[Kind::Skills],
            &[Provider::Codex],
            ContextSelection::Active,
            Some(200_000),
            Some(10_000),
        )
        .unwrap();

        assert_eq!(reports[0].item_count, 1);
        assert_eq!(reports[0].items[0].name, "enabled-skill");
        assert_eq!(reports[0].items[0].status, InstallStatus::Enabled);
        assert!(reports[0].frontmatter_bytes > 0);
        assert!(reports[0].frontmatter_budget.is_some());
        assert!(reports[0].codex_skill_budget.is_some());
    }
}
