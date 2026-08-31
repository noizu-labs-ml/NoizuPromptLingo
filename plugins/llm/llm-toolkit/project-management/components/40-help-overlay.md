# 40: Help Overlay

| Field | Value |
|-------|-------|
| ID | CMP-40 |
| Category | Modals & Overlays |
| Surfaces | tui-ratatui |
| Used In | SCR-36, SCR-37, SCR-40 |

## Description
Full keybinding reference overlay for skill-manage's TUI (US-040's "keyboard shortcuts reference panel" concept, realized here for the ratatui surface specifically) — grouped by action category, dismissible with the same key that opened it.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | 70% × 70% centered overlay, yellow border, `Clear` beneath |

## Props / Configuration
- Static content — grouped key/action pairs plus mode-specific sub-legends (Edit meta, Replace confirm)

## Interactions
- `?` opens from any screen it's available on; `Esc` or `?` again closes
