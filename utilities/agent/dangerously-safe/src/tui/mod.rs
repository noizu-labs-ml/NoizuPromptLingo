//! Interactive wizard.
//!
//! The TUI only *gathers decisions*; the heavy, terminal-owning operations
//! (docker build, docker run) happen after the TUI is torn down so they get the
//! real terminal. `ratatui::init` installs a panic hook that restores the
//! terminal, so a panic mid-wizard won't corrupt the user's shell.

mod widgets;
pub mod fixtures;

use crate::config::{self, Project, SandboxConfig};
use crate::docker;
use crate::error::Result;
use crate::image::{self, AppSet, ImagePlan, SnippetLibrary};
use crate::inference;
use crate::launch::{self, LaunchRequest};
use crate::worktree;
use ratatui::DefaultTerminal;
use serde_yaml::Value;
use std::path::PathBuf;

/// What the user chose for the worktree to run in.
enum WorktreeChoice {
    Existing(PathBuf),
    New(String),
}

/// The complete set of decisions gathered by the wizard.
struct Decisions {
    app_set: AppSet,
    plan: ImagePlan,
    worktree: WorktreeChoice,
    cfg: SandboxConfig,
}

/// Run the TUI wizard with static fixture data — no docker daemon, git repo, or
/// network inference service required. Useful for screenshots and manual testing.
pub async fn demo() -> Result<()> {
    let mut terminal = ratatui::init();
    let result = wizard_demo(&mut terminal);
    ratatui::restore();
    match result {
        Ok(Some(_)) => println!("preview: wizard completed (no action taken)."),
        Ok(None) => println!("preview: cancelled."),
        Err(e) => return Err(e),
    }
    Ok(())
}

/// Like [`wizard`] but driven by fixture data instead of live infrastructure.
fn wizard_demo(terminal: &mut DefaultTerminal) -> Result<Option<()>> {
    let cfg = fixtures::fixture_config();

    let available = fixtures::FIXTURE_SNIPPETS.join(", ");
    let prompt = format!("Available snippets: {available}");
    let initial = cfg.apps.join(",");
    let apps_str = match widgets::text_input(terminal, "Apps (preview)", &prompt, &initial)? {
        Some(s) => s,
        None => return Ok(None),
    };
    let app_slugs: Vec<String> = apps_str
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();
    if app_slugs.is_empty() {
        return Ok(None);
    }

    let worktrees = fixtures::fixture_worktrees();
    let mut items: Vec<String> = worktrees
        .iter()
        .map(|w| format!("{}  [{}]  {}", w.slug(), w.branch, w.status.summary()))
        .collect();
    items.push("➕ new worktree".to_string());
    let new_idx = items.len() - 1;

    let idx = match widgets::select_list(terminal, "Worktrees (preview)", "Pick a worktree", &items)? {
        Some(i) => i,
        None => return Ok(None),
    };

    if idx == new_idx {
        let desc = match widgets::text_input(
            terminal,
            "New worktree (preview)",
            "What are you working on today?",
            "",
        )? {
            Some(s) => s,
            None => return Ok(None),
        };
        if desc.trim().is_empty() {
            return Ok(None);
        }
        let suggestion = inference::fallback_slug(&desc);
        match widgets::text_input(
            terminal,
            "Branch name (preview)",
            "Edit or accept the suggested branch name",
            &suggestion,
        )? {
            Some(s) if !s.is_empty() => {}
            _ => return Ok(None),
        }
    }

    let plan = fixtures::fixture_plan();
    let body = format!(
        "{}\n\nImage will be built or reused before launching.",
        plan.summary()
    );
    if !widgets::confirm(terminal, "Image plan (preview)", &body)? {
        return Ok(None);
    }

    Ok(Some(()))
}

pub async fn run() -> Result<()> {
    let project = Project::discover()?;

    if !docker::is_available() {
        anyhow::bail!("docker is not available; run `agent-sandbox doctor` for details");
    }

    let snippets = SnippetLibrary::load()?;

    let mut terminal = ratatui::init();
    let result = wizard(&mut terminal, &project, &snippets);
    ratatui::restore();

    let decisions = match result {
        Ok(Some(d)) => d,
        Ok(None) => {
            println!("cancelled.");
            return Ok(());
        }
        Err(e) => return Err(e),
    };

    execute(&project, &snippets, decisions)
}

/// Run the interactive screens and collect [`Decisions`].
fn wizard(
    terminal: &mut DefaultTerminal,
    project: &Project,
    snippets: &SnippetLibrary,
) -> Result<Option<Decisions>> {
    // 1. Config bootstrap (with parent-config layering).
    let parent_layers = config::parent_config_values(project)?;
    let mut cfg = if project.has_config() {
        project.load_effective()?
    } else {
        match bootstrap_config(terminal, &parent_layers)? {
            Some(c) => c,
            None => return Ok(None),
        }
    };

    // 2. App set (pre-filled from config; editable).
    let available: Vec<String> = snippets.available().map(|s| s.to_string()).collect();
    let prompt = format!("Available snippets: {}", available.join(", "));
    let initial = cfg.apps.join(",");
    let apps_str = match widgets::text_input(terminal, "Apps", &prompt, &initial)? {
        Some(s) => s,
        None => return Ok(None),
    };
    let app_slugs: Vec<String> = apps_str
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();
    if app_slugs.is_empty() {
        return Ok(None);
    }
    let app_set = AppSet::from_slugs(&app_slugs);
    cfg.apps = app_slugs;

    // 3. Worktree selection.
    let worktree = match pick_worktree(terminal, project, &cfg)? {
        Some(w) => w,
        None => return Ok(None),
    };

    // 4. Resolve & confirm the image plan.
    let plan = image::resolve_image(&app_set, &cfg.image, snippets)?;
    let body = format!(
        "{}\n\nImage will be built or reused before launching.",
        plan.summary()
    );
    if !widgets::confirm(terminal, "Image plan", &body)? {
        return Ok(None);
    }

    Ok(Some(Decisions {
        app_set,
        plan,
        worktree,
        cfg,
    }))
}

/// Offer to start from a parent config, an installed template, or an empty
/// config. Templates and the parent chain are layered (template <- parent).
fn bootstrap_config(
    terminal: &mut DefaultTerminal,
    parent_layers: &[Value],
) -> Result<Option<SandboxConfig>> {
    let templates = config::list_templates().unwrap_or_default();
    let has_parents = !parent_layers.is_empty();

    let mut items = Vec::new();
    if has_parents {
        items.push("Inherit parent config".to_string());
    }
    items.push("Empty config".to_string());
    items.extend(templates.iter().map(|t| format!("Template: {t}")));

    let idx = match widgets::select_list(
        terminal,
        "No .agent-sandbox/config found",
        "Start from",
        &items,
    )? {
        Some(i) => i,
        None => return Ok(None),
    };

    let choice = items[idx].as_str();
    if choice == "Inherit parent config" {
        Ok(Some(config::materialize(parent_layers)?))
    } else if choice == "Empty config" {
        Ok(Some(SandboxConfig::default()))
    } else {
        let name = choice.strip_prefix("Template: ").unwrap_or(choice);
        let mut layers = vec![config::template_value(name)?];
        layers.extend_from_slice(parent_layers);
        Ok(Some(config::materialize(&layers)?))
    }
}

/// List existing worktrees and let the user pick one or create a new one.
fn pick_worktree(
    terminal: &mut DefaultTerminal,
    project: &Project,
    cfg: &SandboxConfig,
) -> Result<Option<WorktreeChoice>> {
    let worktrees = worktree::list_worktrees(project, &cfg.worktree.root)?;

    let mut items: Vec<String> = worktrees
        .iter()
        .map(|w| format!("{}  [{}]  {}", w.slug(), w.branch, w.status.summary()))
        .collect();
    items.push("➕ new worktree".to_string());
    let new_idx = items.len() - 1;

    let idx = match widgets::select_list(terminal, "Worktrees", "Pick a worktree", &items)? {
        Some(i) => i,
        None => return Ok(None),
    };

    if idx == new_idx {
        let desc = match widgets::text_input(
            terminal,
            "New worktree",
            "What are you working on today?",
            "",
        )? {
            Some(s) => s,
            None => return Ok(None),
        };
        if desc.trim().is_empty() {
            return Ok(None);
        }

        // Suggest a branch slug via inference (with deterministic fallback).
        let suggestion = suggest_branch(terminal, &desc)?;

        let name = match widgets::text_input(
            terminal,
            "Branch name",
            "Edit or accept the suggested branch name",
            &suggestion,
        )? {
            Some(s) => s,
            None => return Ok(None),
        };
        let slug = inference::fallback_slug(&name);
        if slug.is_empty() {
            return Ok(None);
        }
        Ok(Some(WorktreeChoice::New(slug)))
    } else {
        Ok(Some(WorktreeChoice::Existing(worktrees[idx].path.clone())))
    }
}

/// Generate a branch-name suggestion: inference if configured, else deterministic.
/// Blocks briefly; shows a "thinking" frame first.
fn suggest_branch(terminal: &mut DefaultTerminal, desc: &str) -> Result<String> {
    if !inference::is_configured() {
        return Ok(inference::fallback_slug(desc));
    }
    widgets::note(
        terminal,
        "Branch name",
        "Generating a branch name from your description…",
    )?;
    // We're inside a sync wizard on a multi-thread tokio runtime; run the async
    // inference call to completion without blocking the reactor's worker pool.
    let result = tokio::task::block_in_place(|| {
        tokio::runtime::Handle::current().block_on(inference::branch_slug(desc))
    });
    Ok(result.unwrap_or_else(|_| inference::fallback_slug(desc)))
}

/// After the TUI is torn down: build the image, create the worktree if needed,
/// and launch the interactive container.
fn execute(project: &Project, snippets: &SnippetLibrary, d: Decisions) -> Result<()> {
    println!("{}", d.plan.summary());
    let image = image::build(&d.plan, snippets)?;
    println!("image ready: {image}");

    let (worktree_path, is_new) = match d.worktree {
        WorktreeChoice::Existing(p) => (p, false),
        WorktreeChoice::New(slug) => {
            let origin = worktree::current_branch(project)?;
            let outcome = worktree::create_worktree(project, &d.cfg.worktree, &slug, &origin)?;
            for w in &outcome.warnings {
                eprintln!("warning: {w}");
            }
            println!(
                "created worktree {} (branch {})",
                outcome.path.display(),
                outcome.branch
            );
            (outcome.path, true)
        }
    };

    let req = LaunchRequest {
        project_root: project.root.clone(),
        worktree: worktree_path,
        image,
        cfg: d.cfg,
        is_new_worktree: is_new,
    };
    let _ = &d.app_set; // app set is captured in the plan/image already
    let code = launch::prepare_and_run(&req)?;
    if code != 0 {
        std::process::exit(code);
    }
    Ok(())
}
