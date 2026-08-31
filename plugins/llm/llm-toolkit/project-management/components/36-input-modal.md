# 36: Input Modal / Inline Edit

| Field | Value |
|-------|-------|
| ID | CMP-36 |
| Category | Modals & Overlays |
| Surfaces | web, cli-ink, tui-ratatui |
| Used In | SCR-04, SCR-17, SCR-19, SCR-21, SCR-23, SCR-25, SCR-26, SCR-38 |

## Description
Focused single- or multi-field text-capture pattern used for everything from renaming a project inline to editing catalog metadata in skill-manage's TUI. Two flavors: **inline** (the field itself becomes editable in place — web `InlineEdit`, cli-ink `InlineEdit.tsx`) and **overlay** (a centered modal captures input over a dimmed/cleared background — cli-ink `InputModal.tsx`, ratatui's Edit Metadata modal).

## Size Variants

| Variant | Use Case |
|---------|---------|
| Inline | Project title/description edit, thread title/slug/description edit |
| Overlay, single-field | Rename, tag, clone, save-prompt, create-name |
| Overlay, multi-field (tui) | Edit Metadata modal — tags / work_types / notes, `Tab` between fields |

## Props / Configuration
- `fields` — one or more `{ label, value, cursorVisible }`
- `activeFieldIndex` — for multi-field overlays

## Interactions
- `Enter` (inline) or `F2`/`Ctrl+S` (tui overlay) commits; `Esc` cancels without saving
- `Tab` moves between fields in multi-field overlays
