mod audit;
mod cmd;
mod crypto;
mod envrc;
mod infisical;
mod kube;
mod secret;
mod secretcmp;
mod secretsmap;
mod settings;
mod shadow;
mod store;
mod target;
mod yaml;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "dc", version, about = "YAML-backed configuration layer for direnv")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Merge YAML from stdin into a named config
    Yaml {
        name: String,
        #[arg(long)]
        layer: Option<String>,
        #[arg(long)]
        replace: bool,
        #[arg(long, value_name = "KEY")]
        replace_key: Option<String>,
        #[arg(long)]
        if_missing: bool,
        #[arg(long)]
        no_bump: bool,
    },
    /// Read a config value by path
    Get {
        name: String,
        path: Option<String>,
        #[arg(long)]
        raw: bool,
        /// Env var that overrides dc (env wins)
        #[arg(long, value_name = "ENV_VAR")]
        r#override: Option<String>,
        /// Env var fallback if dc misses (dc wins)
        #[arg(long, value_name = "ENV_VAR")]
        fallback: Option<String>,
        /// Auto-generate if all sources miss: password|hex [length]
        #[arg(long, value_name = "TYPE", num_args = 1..=2)]
        auto: Vec<String>,
        /// Static default if all sources miss (lower priority than --auto)
        #[arg(long, value_name = "VALUE")]
        default: Option<String>,
        /// Decrypt and print an encrypted secret value (audited)
        #[arg(long)]
        reveal: bool,
        /// Decrypt and copy the value to the clipboard instead of stdout (audited, macOS)
        #[arg(long)]
        clippy: bool,
        /// Decrypt a ⛔ shadowed/restricted secret (stricter than --reveal, audited)
        #[arg(long)]
        reveal_restricted: bool,
    },
    /// Set a config value
    Set {
        name: String,
        key: String,
        value: String,
        #[arg(long)]
        layer: Option<String>,
        #[arg(long)]
        no_bump: bool,
    },
    /// Remove a key from a named config
    Unset {
        name: String,
        keys: Vec<String>,
        #[arg(long)]
        layer: Option<String>,
        #[arg(long)]
        no_bump: bool,
    },
    /// Remove named configs or branches within them
    Prune {
        name: String,
        keys: Vec<String>,
        #[arg(long)]
        layer: Option<String>,
        #[arg(long)]
        no_bump: bool,
    },
    /// Export resolved config as shell env vars
    Env {
        #[arg(long)]
        list: bool,
        #[arg(long)]
        diff: bool,
    },
    /// Bump the version counter
    Bump,
    /// Initialize a config store for the current directory
    Init {
        #[arg(long)]
        from_envrc: Option<String>,
    },
    /// Show current config state
    Status,
    /// List all known config stores
    List,
    /// Permanently delete a named config (or the entire store if no name given)
    Purge {
        /// Config name to purge (omit to purge entire store)
        name: Option<String>,
        /// Hard delete — remove files without writing tombstones
        #[arg(long)]
        hard: bool,
    },
    /// List secret key names per config
    Secrets {
        #[arg(long)]
        json: bool,
    },
    /// Browse/search config entries with secrets masked (pipes to bat if available)
    Bat {
        /// Config subject (omit with --all)
        subject: Option<String>,
        /// Optional dot-path scope within the subject
        scope: Option<String>,
        /// Render every config in the resolved chain
        #[arg(long)]
        all: bool,
        /// Decrypt and show secret values (audited)
        #[arg(long)]
        reveal: bool,
        /// Keep only entries whose full key path matches this regex
        #[arg(long, value_name = "RE")]
        filter_key: Option<String>,
        /// Keep only entries whose value matches this regex
        #[arg(long, value_name = "RE")]
        filter_value: Option<String>,
        /// Drop entries whose full key path matches this regex
        #[arg(long, value_name = "RE")]
        exclude_key: Option<String>,
        /// Drop entries whose value matches this regex
        #[arg(long, value_name = "RE")]
        exclude_value: Option<String>,
    },
    /// Output completion candidates for purge (hidden)
    #[command(name = "__complete-purge", hide = true)]
    CompletePurge,
    /// Locate and edit secrets in source .envrc* files
    Config {
        #[command(subcommand)]
        sub: ConfigCmd,
    },
    /// Compare a local secret against remote targets (no value output)
    Compare {
        layer: String,
        path: String,
        #[arg(long = "to", value_name = "TARGET")]
        to: Vec<String>,
    },
    /// Force-push local secret(s) to a remote (infisical:// or kubernetes://)
    Push {
        subject: String,
        path: String,
        #[arg(long = "to", value_name = "TARGET")]
        to: Vec<String>,
        #[arg(long)]
        dry_run: bool,
        #[arg(long)]
        yes: bool,
    },
    /// Infisical roundtripping (secrets-map driven)
    Infisical {
        #[command(subcommand)]
        sub: InfisicalCmd,
    },
}

#[derive(Subcommand)]
enum InfisicalCmd {
    /// Compare a mapped Infisical secret's local value against targets
    Compare {
        /// Infisical path/NAME (e.g. /data/postgres/POSTGRES_PASSWORD)
        path: String,
        #[arg(long = "to", value_name = "TARGET")]
        to: Vec<String>,
    },
    /// Show live Infisical value next to its dc source (redacted unless --reveal)
    Get {
        name: String,
        #[arg(long)]
        reveal: bool,
    },
    /// Set the dc source for an Infisical secret NAME (edits .envrc in place)
    Set {
        name: String,
        #[arg(long)]
        value: Option<String>,
        #[arg(long, value_name = "FILE")]
        from: Option<String>,
        #[arg(long)]
        stdin: bool,
        #[arg(long)]
        encrypted: bool,
        #[arg(long)]
        yes: bool,
    },
}

#[derive(Subcommand)]
enum ConfigCmd {
    /// Find where a secret is set in .envrc* files
    Get { subject: String, path: String },
    /// Encrypt and write a secret value into its .envrc* source line
    Set {
        subject: String,
        path: String,
        #[arg(long)]
        value: Option<String>,
        #[arg(long, value_name = "FILE")]
        from: Option<String>,
        #[arg(long)]
        stdin: bool,
        /// The provided value is already an encrypted dcenc token
        #[arg(long)]
        encrypted: bool,
        #[arg(long)]
        yes: bool,
    },
    /// Insert a YAML section (from stdin) above/below an anchor entry
    Setall {
        subject: String,
        /// Anchor path to insert above
        #[arg(long, value_name = "PATH")]
        above: Option<String>,
        /// Anchor path to insert below
        #[arg(long, value_name = "PATH")]
        below: Option<String>,
        #[arg(long)]
        yes: bool,
    },
    /// Move a secret into the shadow store, leaving a ⛔ sentinel behind
    Secure {
        subject: String,
        path: String,
        #[arg(long)]
        note: Option<String>,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::Yaml { name, layer, replace, replace_key, if_missing, no_bump } => {
            cmd::yaml::run(&name, layer.as_deref(), replace, replace_key.as_deref(), if_missing, no_bump)
        }
        Commands::Get { name, path, raw, r#override, fallback, auto, default, reveal, clippy, reveal_restricted } => {
            cmd::get::run(&name, path.as_deref(), raw, r#override.as_deref(), fallback.as_deref(), &auto, default.as_deref(), reveal, clippy, reveal_restricted)
        }
        Commands::Set { name, key, value, layer, no_bump } => {
            cmd::set::run(&name, &key, &value, layer.as_deref(), no_bump)
        }
        Commands::Unset { name, keys, layer, no_bump } => {
            cmd::unset::run(&name, &keys, layer.as_deref(), no_bump)
        }
        Commands::Prune { name, keys, layer, no_bump } => {
            cmd::prune::run(&name, &keys, layer.as_deref(), no_bump)
        }
        Commands::Env { list, diff } => {
            cmd::env::run(list, diff)
        }
        Commands::Bump => {
            cmd::bump::run()
        }
        Commands::Init { from_envrc } => {
            cmd::init::run(from_envrc.as_deref())
        }
        Commands::Status => {
            cmd::status::run()
        }
        Commands::List => {
            cmd::list::run()
        }
        Commands::Secrets { json } => {
            cmd::secrets::run(json)
        }
        Commands::Bat { subject, scope, all, reveal, filter_key, filter_value, exclude_key, exclude_value } => {
            cmd::bat::run(
                subject.as_deref(),
                scope.as_deref(),
                all,
                reveal,
                filter_key.as_deref(),
                filter_value.as_deref(),
                exclude_key.as_deref(),
                exclude_value.as_deref(),
            )
        }
        Commands::Purge { name, hard } => {
            cmd::purge::run(name.as_deref(), hard)
        }
        Commands::CompletePurge => {
            cmd::purge::completions()
        }
        Commands::Config { sub } => match sub {
            ConfigCmd::Get { subject, path } => cmd::config::get(&subject, &path),
            ConfigCmd::Set { subject, path, value, from, stdin, encrypted, yes } => {
                cmd::config::set(&subject, &path, value.as_deref(), from.as_deref(), stdin, encrypted, yes)
            }
            ConfigCmd::Setall { subject, above, below, yes } => {
                let (anchor, is_below) = match (above, below) {
                    (Some(a), None) => (a, false),
                    (None, Some(b)) => (b, true),
                    _ => anyhow::bail!("provide exactly one of --above <PATH> or --below <PATH>"),
                };
                let mut buf = String::new();
                std::io::Read::read_to_string(&mut std::io::stdin(), &mut buf)?;
                cmd::config::setall(&subject, &buf, &subject, &anchor, is_below, yes)
            }
            ConfigCmd::Secure { subject, path, note } => {
                shadow::secure(&subject, &path, note.as_deref())
            }
        },
        Commands::Compare { layer, path, to } => {
            cmd::compare::run(&layer, &path, &to)
        }
        Commands::Push { subject, path, to, dry_run, yes } => {
            cmd::push::run(&subject, &path, &to, dry_run, yes)
        }
        Commands::Infisical { sub } => match sub {
            InfisicalCmd::Compare { path, to } => cmd::infisical::compare(&path, &to),
            InfisicalCmd::Get { name, reveal } => cmd::infisical::get(&name, reveal),
            InfisicalCmd::Set { name, value, from, stdin, encrypted, yes } => {
                cmd::infisical::set(&name, value.as_deref(), from.as_deref(), stdin, encrypted, yes)
            }
        },
    }
}
