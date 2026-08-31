# Project Architecture — Summary

## Overview

Single-binary Rust CLI/TUI managing which coding-agent skills, agents, and
commands are enabled per provider (Claude/Codex/Grok) by symlinking provider
install roots into configured source trees. A YAML catalog adds tags,
work-type bundles, and editor profiles; `enable-set --work-type` activates a
curated toolset in one shot. `audit` verifies link health and skill structure.

## Core Components

- `main.rs` — entry point, command dispatch
- `cli.rs` — clap subcommands/flags
- `config.rs` — AppConfig: config.yaml + env overrides + path expansion
- `kinds.rs` — Kind, Provider, InstallStatus, SourceItem types
- `sources.rs` — prioritized source-root discovery, skill structure checks
- `link.rs` — symlink enable/disable/classify with replace+backup safety
- `catalog.rs` — catalog.yaml tags/work_types/editor profiles
- `audit.rs` / `status.rs` — health checks and cross-provider summary
- `tui/` — ratatui interactive mode

## Data Flow

Config load (yaml + SKILL_REPO/AGENT_REPO/COMMAND_REPO env) → source discovery
by priority (lower wins) → per-provider status classification (enabled,
disabled, foreign, real, broken, missing-source) → symlink mutation
(enable/disable/replace, dry-run supported).

## Safety Invariants

Symlinks only; never overwrite real files without `--replace` (timestamped
backup); disable removes only managed symlinks under configured source roots;
never writes Codex `.system/` or Grok bundled trees.

## Ecosystem Fit

Lives in Noizu monorepo `utilities/agent/`; installed to `~/.local/bin` via
`make install-utilities` (dispatched by `utilities/mk/subdirs.mk`). Standalone
Rust binary — does not use k8-lib or `.infra-config.yaml`; config under
`~/.config/skill-manage/`. Canonical enable/disable mechanism for monorepo
`skills/` (`trl-*`) via symlinks, not copies.

## Key Decisions

Symlinks over copies (single canonical source); multi-root with priority
shadowing; catalog is metadata not state (enable state lives on disk); editor
profiles metadata-only in v1; Rust+ratatui chosen over shell for TUI and
multi-state classification.

## Technology Stack

Rust, clap, ratatui + crossterm, serde_yaml, chrono, anyhow; `cargo test` in
install pipeline.
