# Notification Feed

| Field | Value |
|-------|-------|
| **ID** | `notification-feed` |
| **Category** | Tables & Lists |
| **Used In** | 08-Agent Dashboard, 13-Notification Center |

## Description

Chronological list of system and user notifications with type icons, relative timestamps, and read/unread state. Presented as a compact popover for quick access from the nav bar or as a full-page view with tab-based filtering.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dropdown popover with a scrollable list of recent notifications and a mark-all-read control |
| **Expanded** | Full-page feed with tabs for notification types, bulk actions, and infinite scroll or pagination |

## Props / Configuration

- `notifications` — array of notification objects (`id`, `type`, `message`, `href`, `read`, `timestamp`)
- `onMarkRead` — callback invoked with notification id when a single notification is marked read
- `onDismiss` — callback invoked with notification id to remove a notification
- `onMarkAllRead` — callback invoked to mark all notifications as read
- `filterType` — active tab/filter value controlling which notification types are shown
- `loading` — boolean displaying a skeleton or spinner while fetching

## Interactions

- Clicking a notification navigates to `href` and marks it as read via `onMarkRead`
- Dismiss icon on each item calls `onDismiss`
- Mark all read button calls `onMarkAllRead`
- Tab or filter controls update `filterType` to show a subset of notifications
- Unread items render with a visual indicator (dot or bold styling)
