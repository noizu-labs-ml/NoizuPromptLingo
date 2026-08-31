# 32: Command Palette

| Field | Value |
|-------|-------|
| ID | CMP-32 |
| Category | Navigation & Layout |
| Surfaces | web |
| Used In | SCR-01 (global) |

## Description
`Cmd+K` global overlay routing to any page or action from anywhere in the web app, per `design/SITEMAP.md`'s global elements. Not scoped to a single screen — invoked from the persistent AppShell.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Centered modal overlay, fuzzy-matches pages, threads, and actions |

## Props / Configuration
- `query` — fuzzy search text
- `results` — mixed list of page shortcuts, recent threads, and quick actions

## Interactions
- `Cmd+K` opens, `Esc` closes
- Arrow keys navigate results, `Enter` executes/navigates
