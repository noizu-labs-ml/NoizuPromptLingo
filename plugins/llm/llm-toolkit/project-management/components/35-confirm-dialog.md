# 35: Confirm Dialog

| Field | Value |
|-------|-------|
| ID | CMP-35 |
| Category | Modals & Overlays |
| Surfaces | web, cli-ink, tui-ratatui |
| Used In | SCR-04, SCR-09, SCR-10, SCR-19, SCR-21, SCR-24, SCR-25, SCR-26, SCR-39 |

## Description
The universal irreversible-action gate: archive, delete, restore, rehome, and (in skill-manage's TUI) replace-with-symlink all route through the same confirm/cancel pattern before anything destructive happens (US-069, US-084). Directly mirrored across all three surfaces — web modal, cli-ink `ConfirmDialog.tsx` overlay, and ratatui's `draw_confirm` (`Mode::ConfirmReplace`).

## Size Variants

| Variant | Use Case |
|---------|---------|
| Standard | Archive / Delete / Restore / Rehome confirmations |
| Destructive-detail (tui) | Replace-with-symlink confirm — names the exact backup rename operation before proceeding |

## Props / Configuration
- `title`, `body` — action-specific copy naming exactly what will happen
- `confirmLabel` / `cancelLabel` — e.g. "Delete" / "Cancel"
- `destructive` — boolean, drives red/warning styling

## Interactions
- Web: click Confirm/Cancel or `Esc`; cli-ink/tui: `y`/`n` or `Esc`
- Blocks all other input while open
