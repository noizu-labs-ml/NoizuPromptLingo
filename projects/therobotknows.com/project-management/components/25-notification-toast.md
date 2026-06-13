# Notification Toast

| Field | Value |
|-------|-------|
| **ID** | `notification-toast` |
| **Category** | Forms |
| **Used In** | All authenticated screens (global overlay) |

## Description

Ephemeral notification component that appears as a fixed overlay at the bottom-right of the viewport. Communicates success, error, warning, and info states with an icon, message, optional action button, and an auto-dismiss countdown. Multiple toasts stack vertically and can be individually dismissed.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Standard horizontal pill: icon + message + optional action + close button |

## Props / Configuration

- `id` — Unique identifier used for programmatic dismissal
- `type` — `success` | `error` | `warning` | `info`; drives icon and color scheme
- `message` — Primary notification text (keep under 100 characters)
- `description` — Optional secondary line with additional context
- `action` — Optional `{ label: string, onClick: () => void }` object; renders a text button inline
- `duration` — Auto-dismiss duration in milliseconds (default: `4000`; set to `0` to disable auto-dismiss)
- `onDismiss` — Callback fired when the toast is dismissed (auto or manual)
- `persistent` — Boolean alias for `duration: 0`; use for error toasts that require explicit dismissal

## Interactions

- Toast slides in from the bottom-right on mount with a spring animation and slides out on dismiss
- Auto-dismiss timer starts on mount; a thin progress bar at the bottom of the toast visualizes remaining time
- Hovering the toast pauses the auto-dismiss timer; timer resumes when the cursor leaves
- Close button (`×`) dismisses the toast immediately
- Action button fires its `onClick` and then dismisses the toast
- Multiple toasts stack with the newest at the bottom; maximum of 5 toasts visible simultaneously — additional toasts queue and appear as earlier ones dismiss
- Error toasts (`type: error`) default to `persistent: true` to ensure users acknowledge failures
- Accessible: `role="alert"` for errors/warnings, `role="status"` for success/info; announced by screen readers immediately on mount
