# Toast Notification

| Field | Value |
|-------|-------|
| **ID** | toast-notification |
| **Type** | Simple |
| **Category** | Notification |
| **Screen Usage** | Global (all screens)

## Description

Transient notification banner for success, error, warning messages.

## Size Variants

- Standard — Default notification

## Props

- `message` — Notification text
- `type` — success, error, warning, info
- `duration` — Auto-dismiss timeout (ms, 0 = manual)
- `actionLabel` — Optional action button text
- `onAction` — Action button handler
- `onDismiss` — Dismiss handler
- `icon` — Optional icon prefix

## Interactions

- Auto-dismiss after duration
- Manual dismiss with × button
- Click action button (if present)
- Stack multiple notifications vertically
- Entrance/exit animations
- Persist on hover (if duration > 0)

## Accessibility

- `role="status"` or `role="alert"` for errors
- `aria-live="polite"` or `assertive"`
- Auto-focus on appearance (critical errors)
- Keyboard dismiss with Esc