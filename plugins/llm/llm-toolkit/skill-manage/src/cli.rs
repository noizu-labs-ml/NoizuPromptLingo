use crate::context::ContextSelection;
use crate::kinds::{InstallStatus, Kind};
use clap::{Parser, Subcommand, ValueEnum};

#[derive(Parser, Debug)]
#[command(
    name = "skill-manage",
    about = "Manage provider skills, agents, and commands via symlinks + YAML catalog",
    long_about = "Skills, agents, and commands are distinct artifact kinds.\n\
                  This tool only manages configured skill/agent/command source trees and\n\
                  provider install roots — never provider agent runtimes themselves.\n\n\
                  Interactive: skill-manage skills -i  |  agents -i  |  commands -i  |  profiles -i  |  tui"
)]
pub struct Cli {
    /// Path to config.yaml (or set SKILL_MANAGE_CONFIG)
    #[arg(long, global = true)]
    pub config: Option<std::path::PathBuf>,

    /// Override catalog path
    #[arg(long, global = true)]
    pub catalog: Option<std::path::PathBuf>,

    #[arg(short, long, global = true)]
    pub verbose: bool,

    #[arg(short, long, global = true)]
    pub quiet: bool,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// List discovered items and install status
    List {
        #[arg(value_enum, default_value_t = KindFilter::All)]
        kind: KindFilter,

        /// Provider: claude|codex|grok|all
        #[arg(long)]
        provider: Option<String>,

        #[arg(long)]
        tag: Option<String>,

        #[arg(long = "work-type")]
        work_type: Option<String>,

        #[arg(long, value_enum)]
        status: Option<InstallStatus>,
    },

    /// Browse / toggle skills (list by default; -i for TUI)
    Skills {
        /// Interactive TUI
        #[arg(short = 'i', long)]
        interactive: bool,

        #[arg(long)]
        provider: Option<String>,
    },

    /// Browse / toggle agent definitions (-i for TUI)
    Agents {
        #[arg(short = 'i', long)]
        interactive: bool,

        #[arg(long)]
        provider: Option<String>,
    },

    /// Browse / toggle slash commands (-i for TUI)
    Commands {
        #[arg(short = 'i', long)]
        interactive: bool,

        #[arg(long)]
        provider: Option<String>,
    },

    /// Work-type profiles TUI / list
    Profiles {
        #[arg(short = 'i', long)]
        interactive: bool,

        #[arg(long)]
        provider: Option<String>,
    },

    /// Full-screen TUI hub (optional starting screen)
    Tui {
        #[arg(value_enum)]
        screen: Option<TuiScreen>,

        #[arg(long)]
        provider: Option<String>,
    },

    /// Enable (symlink) items into provider dirs
    Enable {
        #[arg(value_enum)]
        kind: Kind,

        /// Item name, or omit with --all
        name: Option<String>,

        #[arg(long)]
        all: bool,

        #[arg(long)]
        provider: Option<String>,

        #[arg(long)]
        replace: bool,

        #[arg(long)]
        dry_run: bool,
    },

    /// Disable (remove managed symlink)
    Disable {
        #[arg(value_enum)]
        kind: Kind,

        name: Option<String>,

        #[arg(long)]
        all: bool,

        #[arg(long)]
        provider: Option<String>,

        #[arg(long)]
        dry_run: bool,
    },

    /// Enable catalog-recommended set for a work type
    EnableSet {
        #[arg(long = "work-type", required = true)]
        work_type: String,

        #[arg(long)]
        provider: Option<String>,

        #[arg(long)]
        replace: bool,

        #[arg(long)]
        dry_run: bool,
    },

    /// Audit structure + install matrix + catalog
    Audit {
        #[arg(value_enum, default_value_t = KindFilter::All)]
        kind: KindFilter,

        #[arg(long)]
        provider: Option<String>,

        #[arg(long)]
        strict: bool,

        #[arg(long)]
        json: bool,
    },

    /// Summary counts per kind × provider
    Status,

    /// Measure selected frontmatter and provider context-budget usage
    Context {
        #[arg(value_enum, default_value_t = KindFilter::All)]
        kind: KindFilter,

        /// Provider: claude|codex|grok|all
        #[arg(long)]
        provider: Option<String>,

        /// Count active provider entries, managed symlinks only, or all sources
        #[arg(long, value_enum, default_value_t = ContextSelection::Active)]
        selection: ContextSelection,

        /// Model context window in tokens; Codex budgets 2% for skill metadata
        #[arg(long)]
        context_window: Option<usize>,

        /// Optional raw frontmatter byte cap for any provider/runner
        #[arg(long)]
        frontmatter_limit_bytes: Option<usize>,

        #[arg(long)]
        json: bool,
    },

    /// Catalog operations
    Catalog {
        #[command(subcommand)]
        action: CatalogCmd,
    },

    /// Work type listing / detail
    WorkTypes {
        #[command(subcommand)]
        action: Option<WorkTypesCmd>,
    },

    /// Print resolved source path for an item
    Path {
        #[arg(value_enum)]
        kind: Kind,
        name: String,
    },

    /// Write starter config.yaml
    InitConfig {
        #[arg(long)]
        force: bool,
    },
}

#[derive(Debug, Clone, Copy, ValueEnum, PartialEq, Eq)]
pub enum TuiScreen {
    Skills,
    Agents,
    Commands,
    Profiles,
}

#[derive(Subcommand, Debug)]
pub enum CatalogCmd {
    /// Write example catalog if missing
    Init {
        #[arg(long)]
        force: bool,
    },
    /// Print catalog path and summary
    Show,
    /// Validate catalog against discovered sources
    Validate,
    /// Print catalog file path
    EditPath,
}

#[derive(Subcommand, Debug)]
pub enum WorkTypesCmd {
    List,
    Show { name: String },
}

#[derive(Debug, Clone, Copy, ValueEnum, PartialEq, Eq)]
pub enum KindFilter {
    Skills,
    Agents,
    Commands,
    All,
}

impl KindFilter {
    // ⟦𓁣𓁙𓅧𓋗⟧ kinds :: auto-generated pointer for public function kinds
    pub fn kinds(self) -> Vec<Kind> {
        match self {
            KindFilter::Skills => vec![Kind::Skills],
            KindFilter::Agents => vec![Kind::Agents],
            KindFilter::Commands => vec![Kind::Commands],
            KindFilter::All => Kind::all().to_vec(),
        }
    }
}
