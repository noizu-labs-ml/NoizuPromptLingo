# 40: TUI Help Overlay

| Field | Value |
|-------|-------|
| ID | SCR-40 |
| Surface | tui-ratatui |
| Type | modal |
| Category | skill-manage (core) |
| Route / Entry | `?` from any screen, `Mode::Help` |
| Primary Personas | P-004, P-008 |
| User Stories | US-077, US-078, US-096 |

## Description
Full key-legend overlay (70% × 70%, yellow border) listing every keybinding available across the Catalog Browser and Profiles screens plus the Edit/Replace modal shortcuts, so a user never has to leave the tool to remember a binding.

## Entry Points
- `?` from Catalog Browser (SCR-36) or Profiles (SCR-37)

## Key Components
- Static help text block, grouped by action: navigation, toggle/replace/edit, filter/status/provider cycling, screen switching, apply/reload/quit, plus the Edit-meta and Replace confirmation sub-legends

## States
- **Modal:** overlays the current screen with `Clear`; underlying screen state is preserved untouched

## Interactions
- `Esc` or `?` — close and return to the underlying screen

## Navigation
- **From:** SCR-36, SCR-37
- **To:** back to whichever screen it was opened from
