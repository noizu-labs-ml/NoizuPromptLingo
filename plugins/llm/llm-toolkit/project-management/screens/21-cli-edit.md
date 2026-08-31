# 21: CLI Edit

| Field | Value |
|-------|-------|
| ID | SCR-21 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `edit` (via `e` from CLI Thread) |
| Primary Personas | P-002, P-006 |
| User Stories | US-041, US-042, US-043, US-044, US-045, US-046 |

## Description
Terminal non-destructive thread editor — the CLI counterpart to Web Thread Editor (SCR-05). Multi-select messages with spacebar, then apply bulk actions (compress/simplify/delete/role-change) or insert template content, all against a draft that's explicitly persisted or finalized as a new version.

## Entry Points
- `e` from CLI Thread (SCR-19)

## Key Components
- SelectableList with multi-select (checkbox-style `SelectedLine` state per row)
- InputModal — insert-template, role-select overlays
- ConfirmDialog — confirm-delete, confirm-revert overlays

## States
- **Draft:** in-progress edits held client-side; `s` explicitly persists the draft without finalizing
- **Confirm overlays:** `confirm-delete` and `confirm-revert` block further input until confirmed/cancelled
- **Bulk action running:** brief inline status while bulk compress/simplify LLM calls resolve

## Interactions
Exact key bindings (from `EditPage.tsx`):
- `Space` — toggle selection of the focused message
- `e` — edit selected message inline
- `i` — insert-template overlay
- `d` — confirm-delete overlay for selection
- `r` — role-select overlay for selection
- `s` — save/persist draft (non-finalizing)
- `f` — finalize (save as new version)
- `u` — confirm-revert overlay (discard draft)
- `A` / `X` — select-all / deselect-all (typical shift-key convention in this app)
- `K` — bulk compress selection
- `L` — bulk simplify selection (LLM-assisted)

## Navigation
- **From:** SCR-19 CLI Thread
- **To:** SCR-19 (on finalize/discard)
