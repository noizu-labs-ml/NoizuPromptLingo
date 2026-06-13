# Toast Notification

| Field | Value |
|-------|-------|
| **ID** | `toast-notification` |
| **Category** | Feedback & Indicators |
| **Used In** | 17-Thread View, 18-Thread Creation, 25-Resource Creation, 42-Notification Settings |

## Description

Transient feedback overlay showing success, warning, or error messages. Auto-dismisses after a configurable duration.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line toast with icon + message |

## Props / Configuration

- `type` — Success, Warning, Error, Info
- `message` — Toast content
- `duration` — Auto-dismiss time (default 3s)
- `action` — Optional action button

## Interactions

- Appears → auto-dismisses; click action → execute
