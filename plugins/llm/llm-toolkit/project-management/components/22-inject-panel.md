# 22: Inject Panel

| Field | Value |
|-------|-------|
| ID | CMP-22 |
| Category | Modals & Overlays |
| Surfaces | web, cli-ink |
| Used In | SCR-05, SCR-21 |

## Description
Slide-out (web) / overlay (cli-ink, `insert-template` mode) panel for adding an annotation, correction, or context message at a chosen insertion point in the edited draft.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Slide-out (web) | Right-edge panel, editor content dims behind it |
| Overlay (cli-ink) | Centered InputModal-style overlay |

## Props / Configuration
- `insertionIndex` — where in the draft the new message will land
- `role` — role of the injected message (typically `user`/system-note)
- `content` — text content being injected

## Interactions
- Confirm inserts the message into EditedPane at the chosen index; Cancel discards
