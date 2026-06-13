//! agent-sandbox — TUI + docker builder for running coding agents safely in
//! isolated git worktrees.
//!
//! A bare invocation launches the TUI (the normal path). Subcommands expose the
//! image/worktree/launch machinery for scripting and debugging.

mod cli;
mod compose;
mod config;
mod docker;
mod error;
mod image;
mod inference;
mod launch;
mod paths;
mod tui;
mod worktree;

use clap::Parser;
use cli::{Cli, Command, TemplateAction};
use error::Result;

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        None => tui::run().await,
        Some(Command::BuildImage { apps, dry_run }) => cmd_build_image(apps, dry_run),
        Some(Command::ListImages) => cmd_list_images(),
        Some(Command::Doctor) => cmd_doctor(),
        Some(Command::Template { action }) => match action {
            TemplateAction::List => cmd_template_list(),
            TemplateAction::Save { name } => cmd_template_save(&name),
        },
        Some(Command::Preview) => tui::demo().await,
    }
}

/// Resolve the requested app set (CLI args, else project config), then build or
/// reuse the matching sandbox image.
fn cmd_build_image(apps: Vec<String>, dry_run: bool) -> Result<()> {
    let project = config::Project::discover()?;
    let cfg = project.load_config()?;

    let app_set = if apps.is_empty() {
        image::AppSet::from_slugs(&cfg.apps)
    } else {
        image::AppSet::from_slugs(&apps)
    };

    let snippets = image::SnippetLibrary::load()?;
    let plan = image::resolve_image(&app_set, &cfg.image, &snippets)?;
    println!("{}", plan.summary());

    if dry_run {
        if let Some(dockerfile) = plan.render_dockerfile(&snippets)? {
            println!("\n--- generated Dockerfile ---\n{dockerfile}");
        }
        return Ok(());
    }

    let tag = image::build(&plan, &snippets)?;
    println!("\nimage ready: {tag}");
    Ok(())
}

fn cmd_list_images() -> Result<()> {
    let images = image::list_sandbox_images()?;
    if images.is_empty() {
        println!("no agent-sandbox images found");
        return Ok(());
    }
    for img in images {
        println!("{:<48} apps: {}", img.reference, img.apps.join(","));
    }
    Ok(())
}

fn cmd_doctor() -> Result<()> {
    launch::doctor()
}

fn cmd_template_list() -> Result<()> {
    for name in config::list_templates()? {
        println!("{name}");
    }
    Ok(())
}

fn cmd_template_save(name: &str) -> Result<()> {
    let project = config::Project::discover()?;
    let path = config::save_template(&project, name)?;
    println!("saved template `{name}` -> {}", path.display());
    Ok(())
}
