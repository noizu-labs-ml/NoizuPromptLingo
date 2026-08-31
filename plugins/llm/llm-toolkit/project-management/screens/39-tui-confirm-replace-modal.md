# 39: TUI Confirm Replace Modal

| Field | Value |
|-------|-------|
| ID | SCR-39 |
| Surface | tui-ratatui |
| Type | modal |
| Category | skill-manage (audit) |
| Route / Entry | `r` on an unmanaged (real-path) catalog row in Catalog Browser (SCR-36), `Mode::ConfirmReplace` |
| Primary Personas | P-004, P-008 |
| User Stories | US-094 |

## Description
Small centered overlay (60% × 40%) warning that the focused item is a real, unmanaged file rather than a symlink into the shared source root — exactly the condition `skill-manage audit --strict` (SCR-41) flags as drift. Confirms before destructively renaming the real file to a timestamped `.bak` and replacing it with a managed symlink.

## Entry Points
- `r` on a catalog row whose install status is "real path" / unmanaged

## Key Components
- Warning text block naming the item and describing the exact operation: rename to `*.bak.<timestamp>`, then create a managed symlink

## States
- **Awaiting confirmation:** blocks all other input until `y`/`n`/`Esc` is pressed

## Interactions
- `y` — confirm: rename to backup, create symlink, re-enable
- `n` / `Esc` — cancel, no changes made

## Navigation
- **From:** SCR-36 TUI Catalog Browser
- **To:** SCR-36 (on confirm or cancel)
