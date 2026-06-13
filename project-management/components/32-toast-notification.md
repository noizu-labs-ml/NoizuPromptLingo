# Toast Notification

| Field | Value |
|-------|-------|
| **ID** | `toast-notification` |
| **Category** | Feedback & Indicators |
| **Used In** | 04-Bid Submission Modal, 12-My Tasks Dashboard, 28-Account Settings |

## Description

Ephemeral screen-edge notification that appears briefly following a user action or system event. Supports success, error, warning, and info states. Auto-dismisses after a configurable duration.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icon plus short message; minimal footprint, suitable for confirmations |
| **Expanded** | Message with an optional action link for follow-up navigation or undo |

## Props / Configuration

- `type` — `success` | `error` | `warning` | `info`; drives icon and color
- `message` — primary text content of the notification
- `actionLabel` — optional label for the inline action link
- `actionHref` — URL or route for the action link
- `duration` — milliseconds before auto-dismiss (default: 4000; `0` disables auto-dismiss)
- `onDismiss` — callback invoked on dismiss (auto or manual)

## Interactions

- Auto-dismisses after `duration` ms; progress indicator optional
- Manual close via X button calls `onDismiss`
- Clicking the action link navigates to `actionHref` and dismisses the toast
