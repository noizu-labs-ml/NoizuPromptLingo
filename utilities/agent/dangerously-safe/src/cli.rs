//! Command-line surface. A bare invocation launches the TUI; subcommands expose
//! the underlying machinery for scripting and debugging.

use clap::{Parser, Subcommand};

#[derive(Debug, Parser)]
#[command(
    name = "agent-sandbox",
    about = "Run coding agents safely in isolated docker worktrees",
    version
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Command>,
}

#[derive(Debug, Subcommand)]
pub enum Command {
    /// Build (or reuse) the sandbox image for a comma-separated app set.
    BuildImage {
        /// App slugs, e.g. `node,rust`. Defaults to the project config's `apps`.
        #[arg(value_delimiter = ',')]
        apps: Vec<String>,
        /// Print the resolved plan and generated Dockerfile without building.
        #[arg(long)]
        dry_run: bool,
    },
    /// List local agent-sandbox images and their app sets.
    ListImages,
    /// Check the host environment (docker, git, tools) and report issues.
    Doctor,
    /// Manage project config templates.
    Template {
        #[command(subcommand)]
        action: TemplateAction,
    },
    /// Run the TUI wizard with fixture data — no docker or git required.
    Preview,
}

#[derive(Debug, Subcommand)]
pub enum TemplateAction {
    /// List installed templates.
    List,
    /// Save the current project's config as a named template.
    Save { name: String },
}
