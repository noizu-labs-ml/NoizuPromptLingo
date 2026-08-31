# Project Layout

`skill-manage` is a Rust CLI/TUI utility that lists, enables, disables, and audits
coding-agent **skills**, **agents**, and **commands** by managing symlinks from
provider install roots (Claude / Codex / Grok) into configured source trees,
with a YAML catalog for tags, work types, and editor profiles.

Embedded in parent monorepo path `llm-toolkit/skill-manage/`; parent launcher
exposes it as `llm-toolkit skill …`.

```
skill-manage/
├── src/                        # Rust source (single binary: skill-manage)
│   ├── main.rs                 #   Entry point; module wiring + command dispatch
│   ├── cli.rs                  #   clap CLI definition (subcommands, flags, value enums)
│   ├── config.rs               #   AppConfig: config.yaml load, env overrides, path expansion
│   ├── kinds.rs                #   Core types: Kind, Provider, InstallStatus, SourceItem
│   ├── sources.rs              #   Source-root discovery of skills/agents/commands
│   ├── link.rs                 #   Symlink enable/disable/classify; replace + backup safety
│   ├── catalog.rs              #   catalog.yaml: tags, work_types, editor profiles
│   ├── audit.rs                #   Audit checks (broken links, structure, strict/JSON)
│   ├── status.rs               #   `status` summary across kinds and providers
│   ├── context.rs              #   Context-budget reporting helpers
│   └── tui/                    #   Interactive ratatui TUI (`-i` / `tui` subcommand)
│       ├── mod.rs              #     TUI bootstrap; terminal setup + event loop
│       ├── app.rs              #     App state: screens, filters, toggles, catalog editing
│       └── ui.rs               #     Rendering: lists, status bar, help, profile screens
├── schema/                     # Example YAML (installed to ~/.local/share/skill-manage/schema)
│   ├── config.example.yaml     #   Source roots + provider install paths template
│   └── catalog.example.yaml    #   Tags/work_types/editor-profiles catalog template
├── docs/                       # Documentation
│   ├── howto/
│   │   └── work-type-bundles.md
│   ├── PROJ-ARCH.md
│   ├── PROJ-ARCH.summary.md
│   ├── PROJ-FAQ.md
│   ├── PROJ-FAQ.summary.md
│   ├── PROJ-HOWTO.md
│   ├── PROJ-HOWTO.summary.md
│   ├── PROJ-LAYOUT.md          #   This file
│   └── PROJ-LAYOUT.summary.md
├── .gitignore                  # Ignores /target/ and /coverage/
├── Cargo.toml                  # Package manifest (clap, ratatui, crossterm, serde_yaml, …)
├── Cargo.lock                  # Locked dependency versions
├── CHANGELOG.md                # Crate release notes
├── Makefile                    # compile/test/install targets
└── README.md                   # Usage, TUI keys, config/env vars — start here
```

Note: `target/` (cargo build output) is gitignored and intentionally omitted.

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `~/.config/skill-manage/config.yaml` | Generate with `skill-manage init-config` (or use `SKILL_REPO`/`AGENT_REPO`/`COMMAND_REPO` env vars) |
| `~/.config/skill-manage/catalog.yaml` | Generate with `skill-manage catalog init` |

Install via parent: `make install` in `llm-toolkit/` (builds release binary, installs schema share, symlinks `llm-toolkit`). Or `cargo build --release` in this directory.
