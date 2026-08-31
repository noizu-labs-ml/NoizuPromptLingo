# Changelog — utilities/agent/skill-manage

## [Unreleased]
- Context-budget reporting added: exact aggregate/per-item YAML frontmatter bytes,
  characters, estimated tokens, field sizes, Codex skill metadata estimates, and
  TUI warnings for active selections (2026-07-17)
- NPL FAQ docs added under `docs/`: `PROJ-FAQ.md` + `.summary.md` — why/when/compared-to-what coverage cross-linked to PROJ-HOWTO (2026-07-17)
- NPL howto docs added under `docs/`: `PROJ-HOWTO.md` + `.summary.md`, plus `docs/howto/work-type-bundles.md` extraction for catalog-driven bulk enable (2026-07-17)
- NPL architecture/layout docs added under `docs/`: `PROJ-ARCH.md`, `PROJ-LAYOUT.md` plus their `.summary.md` companions (`ff72b3565bf`, 2026-07-16)

## [m1-initial-tooling] — 2026-07-15 — tag: `utilities-agent-skill-manage/m1-initial-tooling`
Milestone summary: initial landing of the complete skill-manage Rust CLI — symlink-based enable/disable management of coding-agent skills, agents, and slash-commands across provider install roots (Claude / Codex / Grok), with a ratatui TUI and a YAML catalog layer.

### Added
- Rust CLI (`src/main.rs`, `src/cli.rs`) with `list` / `enable` / `disable` / `audit` / `enable-set` subcommands over three managed kinds: skills, agents, commands
- Symlink management core (`src/link.rs`) linking provider install roots into configured source trees; replace-real-path-with-symlink support
- Config system (`src/config.rs`) — `~/.config/skill-manage/` config with `init-config` generator, plus `SKILL_REPO` / `AGENT_REPO` / `COMMAND_REPO` env fallbacks
- YAML catalog (`src/catalog.rs`, `schema/catalog.example.yaml`) for tags, work types, and editor profiles; `enable-set --work-type` bulk enabling
- Audit mode (`src/audit.rs`) with `--strict` for detecting broken/foreign links
- Interactive ratatui TUI (`src/tui/`) — per-kind browsers, profiles view, hub mode, filtering, per-provider toggling via `1`/`2`/`3`
- `Makefile` install target (`~/.local/bin/skill-manage`), `README.md`, example config/catalog schemas
