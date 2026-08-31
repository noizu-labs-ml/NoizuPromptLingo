# 38: TUI Edit Metadata Modal

| Field | Value |
|-------|-------|
| ID | SCR-38 |
| Surface | tui-ratatui |
| Type | modal |
| Category | skill-manage (core) |
| Route / Entry | `e` from Catalog Browser (SCR-36), `Mode::EditMeta` |
| Primary Personas | P-004 |
| User Stories | US-077 |

## Description
Centered overlay (72% × 50% of the terminal, per `centered_rect(72, 50, area)`) for editing a catalog item's metadata — tags, work types, and free-text notes — without leaving the browser screen underneath (rendered with `Clear` + the modal drawn on top).

## Entry Points
- `e` on a focused catalog row in Catalog Browser (SCR-36)

## Key Components
- Three-field form: `tags`, `work_types`, `notes` — each an inline text buffer with a block cursor (`▋`)
- Active-field highlight — the focused field is styled black-on-cyan bold; inactive fields render plain

## States
- **Field focus:** exactly one of the three fields is active at a time; styling makes this unambiguous at a glance
- **Unsaved:** typed changes exist only in the modal's local buffers until explicitly saved

## Interactions
- `Tab` — move to next field
- `F2` or `Ctrl+S` — save and close
- `Esc` — cancel without saving, discarding buffer changes

## Navigation
- **From:** SCR-36 TUI Catalog Browser
- **To:** SCR-36 (on save or cancel)
