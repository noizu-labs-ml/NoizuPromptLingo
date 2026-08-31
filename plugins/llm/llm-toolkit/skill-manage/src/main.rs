mod audit;
mod catalog;
mod cli;
mod config;
mod context;
mod kinds;
mod link;
mod sources;
mod status;
mod tui;

use anyhow::{bail, Context, Result};
use clap::Parser;
use cli::{CatalogCmd, Cli, Commands, TuiScreen, WorkTypesCmd};
use config::{init_config, AppConfig};
use kinds::{InstallStatus, Kind, Provider, SourceItem};
use link::{classify, disable_item, enable_item};
use sources::discover;
use std::collections::BTreeMap;
use std::path::PathBuf;
use std::process::ExitCode;
use tui::Screen;

fn main() -> ExitCode {
    match run() {
        Ok(code) => code,
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::from(1)
        }
    }
}

fn run() -> Result<ExitCode> {
    let cli = Cli::parse();
    match &cli.command {
        Commands::InitConfig { force } => {
            let path = cli
                .config
                .clone()
                .unwrap_or_else(AppConfig::default_config_path);
            init_config(&path, *force)?;
            println!("wrote {}", path.display());
            return Ok(ExitCode::SUCCESS);
        }
        _ => {}
    }

    let cfg = AppConfig::load(cli.config.as_deref())?;
    let catalog_path = cli.catalog.clone().or_else(|| cfg.catalog.clone());
    let cat = catalog::Catalog::load(catalog_path.as_deref())?;

    match cli.command {
        Commands::InitConfig { .. } => unreachable!(),
        Commands::List {
            kind,
            provider,
            tag,
            work_type,
            status,
        } => {
            cmd_list(
                &cfg,
                &cat,
                &kind.kinds(),
                provider.as_deref(),
                tag.as_deref(),
                work_type.as_deref(),
                status,
                cli.verbose,
            )?;
        }
        Commands::Skills {
            interactive,
            provider,
        } => {
            if interactive {
                tui::run(
                    cfg,
                    cat,
                    catalog_path,
                    Screen::Skills,
                    tui::parse_provider(provider.as_deref()),
                )?;
            } else {
                cmd_list(
                    &cfg,
                    &cat,
                    &[Kind::Skills],
                    provider.as_deref(),
                    None,
                    None,
                    None,
                    cli.verbose,
                )?;
            }
        }
        Commands::Agents {
            interactive,
            provider,
        } => {
            if interactive {
                tui::run(
                    cfg,
                    cat,
                    catalog_path,
                    Screen::Agents,
                    tui::parse_provider(provider.as_deref()),
                )?;
            } else {
                cmd_list(
                    &cfg,
                    &cat,
                    &[Kind::Agents],
                    provider.as_deref(),
                    None,
                    None,
                    None,
                    cli.verbose,
                )?;
            }
        }
        Commands::Commands {
            interactive,
            provider,
        } => {
            if interactive {
                tui::run(
                    cfg,
                    cat,
                    catalog_path,
                    Screen::Commands,
                    tui::parse_provider(provider.as_deref()),
                )?;
            } else {
                cmd_list(
                    &cfg,
                    &cat,
                    &[Kind::Commands],
                    provider.as_deref(),
                    None,
                    None,
                    None,
                    cli.verbose,
                )?;
            }
        }
        Commands::Profiles {
            interactive,
            provider,
        } => {
            if interactive {
                tui::run(
                    cfg,
                    cat,
                    catalog_path,
                    Screen::Profiles,
                    tui::parse_provider(provider.as_deref()),
                )?;
            } else {
                for (name, wt) in &cat.work_types {
                    println!("{name}: {}", wt.description);
                }
                if cat.work_types.is_empty() {
                    println!("(no work types — skill-manage catalog init, then profiles -i)");
                }
            }
        }
        Commands::Tui { screen, provider } => {
            let scr = match screen.unwrap_or(TuiScreen::Skills) {
                TuiScreen::Skills => Screen::Skills,
                TuiScreen::Agents => Screen::Agents,
                TuiScreen::Commands => Screen::Commands,
                TuiScreen::Profiles => Screen::Profiles,
            };
            tui::run(
                cfg,
                cat,
                catalog_path,
                scr,
                tui::parse_provider(provider.as_deref()),
            )?;
        }
        Commands::Enable {
            kind,
            name,
            all,
            provider,
            replace,
            dry_run,
        } => {
            let names = resolve_names(&cfg, kind, name.as_deref(), all)?;
            let providers = cfg.resolve_providers(provider.as_deref())?;
            let (items, _) = discover(&cfg, kind)?;
            for n in names {
                let Some(item) = items.get(&n) else {
                    eprintln!("skip: unknown {} '{n}'", kind.singular());
                    continue;
                };
                for p in &providers {
                    if let Some(allowed) = cat.allowed_providers(kind, &n) {
                        if !allowed.contains(p) {
                            if !cli.quiet {
                                eprintln!("skip {p}/{kind}/{n}: not in catalog providers");
                            }
                            continue;
                        }
                    }
                    match enable_item(&cfg, *p, item, replace || cfg.defaults.replace, dry_run) {
                        Ok(act) => {
                            if !cli.quiet {
                                println!(
                                    "{} {} {} {} -> {}",
                                    act.message,
                                    act.provider,
                                    act.kind,
                                    act.name,
                                    act.dest.display()
                                );
                            }
                        }
                        Err(e) => eprintln!("error {p}/{kind}/{n}: {e}"),
                    }
                }
            }
        }
        Commands::Disable {
            kind,
            name,
            all,
            provider,
            dry_run,
        } => {
            let names = resolve_names(&cfg, kind, name.as_deref(), all)?;
            let providers = cfg.resolve_providers(provider.as_deref())?;
            let (items, _) = discover(&cfg, kind)?;
            for n in names {
                let item = items.get(&n);
                for p in &providers {
                    match disable_item(&cfg, *p, kind, &n, item, dry_run) {
                        Ok(act) => {
                            if !cli.quiet {
                                println!(
                                    "{} {} {} {}",
                                    act.message, act.provider, act.kind, act.name
                                );
                            }
                        }
                        Err(e) => eprintln!("error {p}/{kind}/{n}: {e}"),
                    }
                }
            }
        }
        Commands::EnableSet {
            work_type,
            provider,
            replace,
            dry_run,
        } => {
            let wt = cat
                .work_types
                .get(&work_type)
                .with_context(|| format!("unknown work type '{work_type}'"))?
                .clone();
            let providers = cfg.resolve_providers(provider.as_deref())?;
            enable_named(
                &cfg,
                &cat,
                Kind::Skills,
                &wt.skills,
                &providers,
                replace,
                dry_run,
                cli.quiet,
            )?;
            enable_named(
                &cfg,
                &cat,
                Kind::Agents,
                &wt.agents,
                &providers,
                replace,
                dry_run,
                cli.quiet,
            )?;
            enable_named(
                &cfg,
                &cat,
                Kind::Commands,
                &wt.commands,
                &providers,
                replace,
                dry_run,
                cli.quiet,
            )?;
            if !cli.quiet {
                for ep in &wt.editor_profiles {
                    if let Some(profile) = cat.editor_profiles.get(ep) {
                        println!("editor profile {ep}: {}", profile.description);
                        for f in &profile.files {
                            let mark = if f.path.exists() { "ok" } else { "MISSING" };
                            println!(
                                "  [{mark}] {} ({})",
                                f.path.display(),
                                f.role.as_deref().unwrap_or("-")
                            );
                        }
                    }
                }
            }
        }
        Commands::Audit {
            kind,
            provider,
            strict,
            json,
        } => {
            let providers = cfg.resolve_providers(provider.as_deref())?;
            let report = audit::run_audit(&cfg, &cat, &kind.kinds(), &providers)?;
            if json {
                println!("{}", serde_json::to_string_pretty(&report)?);
            } else {
                print!("{}", audit::format_text(&report));
            }
            if strict && audit::has_strict_failures(&report) {
                return Ok(ExitCode::from(2));
            }
        }
        Commands::Status => {
            status::print_status(&cfg)?;
        }
        Commands::Context {
            kind,
            provider,
            selection,
            context_window,
            frontmatter_limit_bytes,
            json,
        } => {
            let providers = cfg.resolve_providers(provider.as_deref())?;
            let reports = context::build_reports(
                &cfg,
                &kind.kinds(),
                &providers,
                selection,
                context_window,
                frontmatter_limit_bytes,
            )?;
            if json {
                println!("{}", serde_json::to_string_pretty(&reports)?);
            } else {
                print!("{}", context::format_text(&reports));
            }
        }
        Commands::Catalog { action } => match action {
            CatalogCmd::Init { force } => {
                let path = catalog_path
                    .clone()
                    .unwrap_or_else(|| default_catalog_path());
                catalog::Catalog::init_example(&path, force)?;
                println!("wrote {}", path.display());
            }
            CatalogCmd::Show => {
                let path = catalog_path
                    .as_ref()
                    .map(|p| p.display().to_string())
                    .unwrap_or_else(|| "(none)".into());
                println!("catalog: {path}");
                println!(
                    "skills={} agents={} commands={} work_types={} editor_profiles={}",
                    cat.skills.len(),
                    cat.agents.len(),
                    cat.commands.len(),
                    cat.work_types.len(),
                    cat.editor_profiles.len()
                );
            }
            CatalogCmd::Validate => {
                let mut known = BTreeMap::new();
                for kind in Kind::all() {
                    let (items, _) = discover(&cfg, kind)?;
                    known.insert(kind, items.keys().cloned().collect());
                }
                let (errors, warnings) = cat.validate(&known);
                for e in &errors {
                    println!("error: {e}");
                }
                for w in &warnings {
                    println!("warn: {w}");
                }
                if errors.is_empty() {
                    println!("catalog valid ({} warnings)", warnings.len());
                } else {
                    bail!("catalog has {} error(s)", errors.len());
                }
            }
            CatalogCmd::EditPath => {
                let path = catalog_path.unwrap_or_else(default_catalog_path);
                println!("{}", path.display());
            }
        },
        Commands::WorkTypes { action } => match action.unwrap_or(WorkTypesCmd::List) {
            WorkTypesCmd::List => {
                for (name, wt) in &cat.work_types {
                    println!("{name}: {}", wt.description);
                }
                if cat.work_types.is_empty() {
                    println!("(no work types in catalog)");
                }
            }
            WorkTypesCmd::Show { name } => {
                let wt = cat
                    .work_types
                    .get(&name)
                    .with_context(|| format!("unknown work type '{name}'"))?;
                println!("{name}: {}", wt.description);
                println!("  skills:   {}", wt.skills.join(", "));
                println!("  agents:   {}", wt.agents.join(", "));
                println!("  commands: {}", wt.commands.join(", "));
                println!("  editor:   {}", wt.editor_profiles.join(", "));
                for ep in &wt.editor_profiles {
                    if let Some(profile) = cat.editor_profiles.get(ep) {
                        println!("  [{ep}] {}", profile.description);
                        for f in &profile.files {
                            let mark = if f.path.exists() { "ok" } else { "MISSING" };
                            println!("    [{mark}] {}", f.path.display());
                        }
                    }
                }
            }
        },
        Commands::Path { kind, name } => {
            let (items, _) = discover(&cfg, kind)?;
            let item = items
                .get(&name)
                .with_context(|| format!("unknown {} '{name}'", kind.singular()))?;
            println!("{}", item.path.display());
        }
    }

    Ok(ExitCode::SUCCESS)
}

fn default_catalog_path() -> PathBuf {
    dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from(".").join(".config"))
        .join("skill-manage")
        .join("catalog.yaml")
}

fn resolve_names(
    cfg: &AppConfig,
    kind: Kind,
    name: Option<&str>,
    all: bool,
) -> Result<Vec<String>> {
    if all {
        let (items, _) = discover(cfg, kind)?;
        return Ok(items.keys().cloned().collect());
    }
    let Some(name) = name else {
        bail!("provide a name or --all");
    };
    Ok(vec![name.to_string()])
}

fn enable_named(
    cfg: &AppConfig,
    cat: &catalog::Catalog,
    kind: Kind,
    names: &[String],
    providers: &[Provider],
    replace: bool,
    dry_run: bool,
    quiet: bool,
) -> Result<()> {
    if names.is_empty() {
        return Ok(());
    }
    let (items, _) = discover(cfg, kind)?;
    for n in names {
        let Some(item) = items.get(n) else {
            eprintln!("skip: unknown {} '{n}'", kind.singular());
            continue;
        };
        for p in providers {
            if let Some(allowed) = cat.allowed_providers(kind, n) {
                if !allowed.contains(p) {
                    continue;
                }
            }
            // Skip providers without this kind dir
            if cfg.kind_dir(*p, kind).is_none() {
                continue;
            }
            match enable_item(cfg, *p, item, replace || cfg.defaults.replace, dry_run) {
                Ok(act) => {
                    if !quiet {
                        println!(
                            "{} {} {} {} -> {}",
                            act.message,
                            act.provider,
                            act.kind,
                            act.name,
                            act.dest.display()
                        );
                    }
                }
                Err(e) => eprintln!("error {p}/{kind}/{n}: {e}"),
            }
        }
    }
    Ok(())
}

fn cmd_list(
    cfg: &AppConfig,
    cat: &catalog::Catalog,
    kinds: &[Kind],
    provider: Option<&str>,
    tag: Option<&str>,
    work_type: Option<&str>,
    status_filter: Option<InstallStatus>,
    verbose: bool,
) -> Result<()> {
    let providers = cfg.resolve_providers(provider)?;
    println!(
        "{:<10} {:<28} {:<12} {}",
        "KIND", "NAME", "PROVIDER", "STATUS"
    );
    for kind in kinds {
        let (items, collisions) = discover(cfg, *kind)?;
        if verbose {
            for (name, a, b) in &collisions {
                eprintln!(
                    "collision {kind}/{name}: {} over {}",
                    a.display(),
                    b.display()
                );
            }
        }
        for (name, item) in &items {
            if !cat.matches_filters(*kind, name, tag, work_type) {
                continue;
            }
            for p in &providers {
                let st = status_for(cfg, *p, item);
                if let Some(filter) = status_filter {
                    if st != filter {
                        continue;
                    }
                }
                let tags = cat.tags_for(*kind, name);
                let tag_s = if tags.is_empty() {
                    String::new()
                } else {
                    format!(" tags=[{}]", tags.join(","))
                };
                let fm = item
                    .frontmatter_name
                    .as_ref()
                    .map(|n| format!(" yaml={n}"))
                    .unwrap_or_default();
                println!(
                    "{:<10} {:<28} {:<12} {}{}{}",
                    kind.as_str(),
                    name,
                    p.as_str(),
                    st,
                    tag_s,
                    if verbose { fm } else { String::new() }
                );
            }
        }
    }
    Ok(())
}

fn status_for(cfg: &AppConfig, provider: Provider, item: &SourceItem) -> InstallStatus {
    let Some(kind_dir) = cfg.kind_dir(provider, item.kind) else {
        return InstallStatus::Disabled;
    };
    let dest = item.dest_path(&kind_dir);
    classify(cfg, item.kind, &dest, Some(&item.path))
}
