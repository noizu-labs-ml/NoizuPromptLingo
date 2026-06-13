use anyhow::Result;

use crate::cli::FetchArgs;
use crate::tui::{self, fetch_view};

use super::creds;

pub async fn run(args: FetchArgs) -> Result<()> {
    let env = args.env_flags.resolve();

    eprintln!("Fetching {} [env={}]", args.path, env);

    let client = creds::build_client(&env).await?;

    let mut secrets = client.list_secrets(&args.path).await?;
    secrets.sort_by(|a, b| a.key.cmp(&b.key));

    let redact = args.redact && !args.show_secrets;

    if !args.quiet {
        eprintln!(
            "Host: {}  Project: {}  Env: {}  Path: {}",
            client.cfg.host, client.cfg.project_id, client.cfg.environment, args.path
        );
    }

    if !args.no_tui && tui::is_tty() {
        fetch_view::FetchView::new(
            secrets,
            args.path.clone(),
            env.clone(),
            redact,
        )
        .run()?;
    } else {
        fetch_view::print_secrets_plain(&secrets, &args.format, redact);
    }

    Ok(())
}
