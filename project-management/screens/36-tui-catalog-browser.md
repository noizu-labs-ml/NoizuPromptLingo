# 36: TUI Catalog Browser

| Field | Value |
|-------|-------|
| ID | SCR-36 |
| Surface | tui-ratatui |
| Type | primary |
| Category | skill-manage (core) |
| Route / Entry | `skill-manage tui` (default screen, `Screen::Skills`) |
| Primary Personas | P-004, P-008 |
| User Stories | US-077, US-078, US-079, US-096 |

## Description
The primary ratatui screen for `skill-manage tui`: a filterable, provider-scoped catalog of skills, agents, and commands across install roots (Claude / Codex / Grok), with inline enable/disable toggling and bulk work-type application. Three tab-like `Screen` variants — `Skills`, `Agents`, `Commands` — share this same `draw_browse` layout, distinguished by which `Kind` of catalog item is listed.

## Entry Points
- `skill-manage tui` cold start (lands on `Screen::Skills`)
- `Tab` cycles forward through Skills → Agents → Commands → Profiles (SCR-37) → back to Skills

## Key Components
- Header bar — current screen name, active provider, active status filter
- Catalog row list — item name, install status (enabled/disabled/unmanaged-real-path), tags
- Footer stats/help line — contextual key legend + item counts

## States
- **Filter active (`Mode::Filter`):** header captures typed filter text; list narrows live, filter shown inline in the header rather than as a separate overlay
- **Provider view:** cycling providers (`p`) re-renders the same row list scoped to the newly selected provider, preserving list position so enabled/disabled state is directly comparable across providers (US-096)
- **Unmanaged/real path:** rows for items that are real files rather than managed symlinks are visually distinguished, feeding into the Confirm Replace modal (SCR-39)

## Interactions
Exact key bindings (from `ui.rs` help text / `app.rs`):
- `↑↓` / `j k` — move selection
- `Space` — toggle enable/disable for the focused item (US-078)
- `r` — replace + enable (converts an unmanaged real path into a managed symlink, via Confirm Replace modal)
- `e` — edit catalog metadata (opens Edit Metadata modal, SCR-38)
- `/` — enter filter mode
- `f` — cycle status filter (e.g. all/enabled/disabled)
- `1` / `2` / `3` — jump directly to claude / codex / grok provider
- `p` — cycle to next provider (US-096)
- `Tab` — next screen (Skills → Agents → Commands → Profiles)
- `A` — apply work-type to selection (bulk-enable a bundle, US-079)
- `R` — reload catalog from disk
- `?` — open Help overlay (SCR-40)
- `q` — quit

## Navigation
- **From:** `skill-manage tui` launch
- **To:** SCR-37 TUI Profiles (Tab), SCR-38 Edit Metadata modal (`e`), SCR-39 Confirm Replace modal (`r` on an unmanaged path), SCR-40 Help overlay (`?`)
