mod api;
mod cli;
mod commands;
mod config;
mod dc;
mod engine;
mod error;
mod tui;

use anyhow::Result;
use clap::Parser;

use cli::{Cli, Command};

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Command::Audit(args) => commands::audit::run(args).await?,
        Command::Bootstrap(args) => commands::bootstrap::run(args)?,
        Command::Fetch(args) => commands::fetch::run(args).await?,
        Command::FindDcLine(args) => commands::find_dc_line::run(args)?,
        Command::Populate(args) => commands::populate::run(args).await?,
        Command::Rebuild(args) => commands::rebuild::run(args).await?,
        Command::Set(args) => commands::set_secret::run(args).await?,
        Command::Verify(args) => commands::verify::run(args).await?,
        Command::ViewDc(args) => commands::view_dc::run(args)?,
    }

    Ok(())
}
