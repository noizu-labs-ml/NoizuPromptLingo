# 39: Status Line / Key Legend

| Field | Value |
|-------|-------|
| ID | CMP-39 |
| Category | Feedback & Indicators |
| Surfaces | cli-ink, tui-ratatui |
| Used In | SCR-16 through SCR-29 (all cli-ink pages), SCR-36, SCR-37 |

## Description
Always-visible footer bar in both terminal surfaces showing the current mode and the keys available in it — the terminal substitute for visible buttons/menus. Cli-ink's `StatusLine.tsx` and ratatui's `draw_footer` serve the identical purpose with surface-appropriate rendering.

## Size Variants

| Variant | Use Case |
|---------|---------|
| cli-ink | One-line footer, updates per page/mode |
| ratatui | Two-line footer (stats line + key hints), per `draw_footer` |

## Props / Configuration
- `mode` — current UI sub-mode, determines which key hints are shown
- `hints` — ordered list of `{ key, label }`

## Interactions
- Purely informational — reflects available actions rather than being interacted with directly
- Full legend available on demand via Help Overlay (CMP-40) where one exists
