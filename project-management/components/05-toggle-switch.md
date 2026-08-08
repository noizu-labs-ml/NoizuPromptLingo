# Toggle Switch

| Field | Value |
|-------|-------|
| **ID** | `toggle-switch` |
| **Category** | Input & Forms |
| **Used In** | 10-admin-users, 18-projects-list, 22-chat-room-list, 26-ticket-detail |

## Description

A binary on/off control for account, subscription, and visibility states — suspend/reinstate, mute/unmute, archived/active, watch/unwatch.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single toggle switch |
| **Compact** | Toggle with adjacent label and current-state text |

## Props / Configuration

- `checked` — current state
- `onToggle` — fires immediately on flip
- `confirmBeforeToggle` — routes the flip through a Modal Dialog confirmation first (used for consequential toggles like account suspension)

## Interactions

- User flips the toggle → state changes immediately, or a confirmation prompt appears first for consequential toggles, then applies on confirm
- Toggling is reflected instantly elsewhere in the UI (e.g. an Archived Project Toggle hides/shows the entity in the bound Data Table)
