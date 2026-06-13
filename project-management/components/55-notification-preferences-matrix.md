# Notification Preferences Matrix

| Field | Value |
|-------|-------|
| **ID** | `notification-preferences-matrix` |
| **Category** | Domain-Specific |
| **Used In** | 13-Notification Center |

## Description

Grid of notification types against delivery channels with per-cell toggles. Includes a Do Not Disturb scheduler, match alert configuration with preset options, and a digest interval selector for batching notifications.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full settings panel with complete type × channel grid, DND scheduler, and match alert preset configuration |

## Props / Configuration

- `notificationTypes[]` — Row definitions (key, label, description, category)
- `channels[]` — Column definitions (key, label) such as email, push, in-app, SMS
- `preferences` — Current state map of notificationType × channel → enabled boolean
- `onToggle` — Callback invoked with (notificationType, channel, newValue) on cell change
- `dndSchedule` — Current DND configuration (enabled, startTime, endTime, timezone)
- `onSetDnd` — Callback to update the DND schedule
- `matchAlertPresets[]` — Predefined match alert configurations selectable as shortcuts

## Interactions

- Toggle individual cells to enable or disable a notification type for a specific channel
- Set a DND window to suppress all notifications during quiet hours
- Select a match alert preset to bulk-configure relevant notification types at once
- Configure digest interval to batch non-urgent notifications into periodic summaries
