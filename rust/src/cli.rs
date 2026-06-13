use clap::{Args, Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(name = "infisical", about = "Infisical secrets management CLI", version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand, Debug)]
pub enum Command {
    /// Audit secrets across .envrc.dc, YAML config, and Infisical
    Audit(AuditArgs),
    /// Bootstrap tier-0 K8s Secrets for Infisical itself
    Bootstrap(BootstrapArgs),
    /// Fetch and display secrets at an Infisical path
    Fetch(FetchArgs),
    /// Locate a dc get directive line in .envrc.dc
    #[command(name = "find-dc-line")]
    FindDcLine(FindDcLineArgs),
    /// Populate Infisical from secrets config
    Populate(PopulateArgs),
    /// Rebuild .envrc.dc and infisical-secrets.yaml from live Infisical state
    Rebuild(RebuildArgs),
    /// Update a single secret in dc and Infisical
    Set(SetArgs),
    /// Verify secret chain integrity
    Verify(VerifyArgs),
    /// View dc get directives from .envrc.dc
    #[command(name = "view-dc")]
    ViewDc(ViewDcArgs),
}

// ── Shared env flag ──────────────────────────────────────────────────────────

#[derive(Args, Debug, Default)]
pub struct EnvFlags {
    #[arg(long, env = "INFISICAL_ENV", help = "Target environment")]
    pub env: Option<String>,
    #[arg(long, conflicts_with_all = ["dev", "env"], help = "Use prod environment")]
    pub prod: bool,
    #[arg(long, conflicts_with_all = ["prod", "env"], help = "Use staging environment")]
    pub stage: bool,
    #[arg(long, conflicts_with_all = ["prod", "stage", "env"], help = "Use dev environment")]
    pub dev: bool,
}

impl EnvFlags {
    pub fn resolve(&self) -> String {
        if self.prod {
            return "prod".into();
        }
        if self.stage {
            return "staging".into();
        }
        if self.dev {
            return "dev".into();
        }
        self.env.clone().unwrap_or_else(|| "prod".into())
    }
}

#[derive(Args, Debug)]
pub struct ConfigFlag {
    #[arg(long, short = 'c', env = "INFISICAL_SECRETS_FILE", help = "Path to secrets config file")]
    pub config: Option<String>,
}

// ── Per-command args ─────────────────────────────────────────────────────────

#[derive(Args, Debug)]
pub struct AuditArgs {
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, value_enum, default_value = "markdown")]
    pub format: AuditFormat,
    #[arg(long, help = "Show actual values in mismatches (sensitive)")]
    pub show_diff: bool,
    #[arg(long, help = "Export report to file")]
    pub export: Option<String>,
    #[arg(long, help = "Disable TUI, output plain text")]
    pub no_tui: bool,
}

#[derive(clap::ValueEnum, Clone, Debug, Default)]
pub enum AuditFormat {
    #[default]
    Markdown,
    Json,
}

#[derive(Args, Debug)]
pub struct BootstrapArgs {
    #[arg(long, help = "Preview kubectl commands without executing")]
    pub dry_run: bool,
    #[arg(long, help = "Create only the TLS secret")]
    pub tls_only: bool,
    #[arg(long, help = "Override namespace")]
    pub namespace: Option<String>,
    #[arg(long, short = 'c', help = "Path to k8-util-config.yaml")]
    pub config: Option<String>,
}

#[derive(Args, Debug)]
pub struct FetchArgs {
    /// Infisical secret path (e.g. /livebook)
    pub path: String,
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, value_enum, default_value = "table")]
    pub format: FetchFormat,
    #[arg(long, help = "Mask credential values in header")]
    pub redact: bool,
    #[arg(long, help = "Show credential values (opposite of --redact)")]
    pub show_secrets: bool,
    #[arg(long, short = 'q', help = "Suppress context header")]
    pub quiet: bool,
    #[arg(long, help = "Disable TUI")]
    pub no_tui: bool,
}

#[derive(clap::ValueEnum, Clone, Debug, Default)]
pub enum FetchFormat {
    #[default]
    Table,
    Env,
    Json,
}

#[derive(Args, Debug)]
pub struct FindDcLineArgs {
    pub scope: String,
    pub item_path: String,
    #[arg(long, help = "Output file:line:content one-liner")]
    pub inline: bool,
    #[arg(long, help = "Prepend absolute path to .envrc.dc")]
    pub env_path: bool,
    #[arg(long, help = "Explicit path to .envrc.dc")]
    pub file: Option<String>,
}

#[derive(Args, Debug)]
pub struct PopulateArgs {
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, help = "Run only this section or group")]
    pub section: Option<String>,
    #[arg(long, help = "List sections/groups and exit")]
    pub list: bool,
    #[arg(long, help = "Hide unchanged secrets in output")]
    pub impacted: bool,
    #[arg(long, help = "Preview without writing")]
    pub dry_run: bool,
    #[arg(long, help = "Include secret values in output")]
    pub show_secrets: bool,
    #[arg(long, help = "Disable TUI progress")]
    pub no_tui: bool,
}

#[derive(Args, Debug)]
pub struct RebuildArgs {
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, value_enum, default_value = "all")]
    pub phase: RebuildPhase,
    #[arg(long, help = "Include actual values in inventory (required for generate phase)")]
    pub show_secrets: bool,
    #[arg(long, default_value = ".rebuild")]
    pub output_dir: String,
    #[arg(long, help = "Preview without writing")]
    pub dry_run: bool,
}

#[derive(clap::ValueEnum, Clone, Debug, Default)]
pub enum RebuildPhase {
    Scan,
    Analyze,
    Generate,
    #[default]
    All,
}

#[derive(Args, Debug)]
pub struct SetArgs {
    /// Secret name from config
    pub name: String,
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, help = "Set value directly")]
    pub value: Option<String>,
    #[arg(long, help = "Auto-generate new value")]
    pub generate: bool,
    #[arg(long, help = "Preview changes without writing")]
    pub dry_run: bool,
    #[arg(long, help = "Find and flag secrets that reference this one")]
    pub cascade: bool,
}

#[derive(Args, Debug)]
pub struct VerifyArgs {
    #[command(flatten)]
    pub env_flags: EnvFlags,
    #[command(flatten)]
    pub config: ConfigFlag,
    #[arg(long, help = "Verify specific section")]
    pub section: Option<String>,
    #[arg(long, help = "Verify single secret by name")]
    pub secret: Option<String>,
    #[arg(long, help = "Exit 1 on first mismatch")]
    pub fail_fast: bool,
    #[arg(long, help = "Show actual values (sensitive)")]
    pub show_values: bool,
    #[arg(long, help = "Export JSON report to file")]
    pub report_file: Option<String>,
    #[arg(long, help = "Disable TUI")]
    pub no_tui: bool,
}

#[derive(Args, Debug)]
pub struct ViewDcArgs {
    #[arg(long, help = "Filter by scope (e.g. secrets, infra)")]
    pub scope: Option<String>,
    #[arg(long, help = "Filter by item path pattern")]
    pub path: Option<String>,
    #[arg(long, help = "Show resolved values via dc get")]
    pub show_values: bool,
    #[arg(long, value_enum, default_value = "table")]
    pub format: ViewDcFormat,
    #[arg(long, help = "Explicit path to .envrc.dc")]
    pub file: Option<String>,
    #[arg(long, help = "Disable TUI")]
    pub no_tui: bool,
}

#[derive(clap::ValueEnum, Clone, Debug, Default)]
pub enum ViewDcFormat {
    #[default]
    Table,
    Json,
}
