# Notification Item

| Field | Value |
|-------|-------|
| **ID** | `notification-item` |
| **Category** | Cards & Tiles |
| **Used In** | 32-Notification Center |

## Description

Single notification row with type icon, summary text, timestamp, and read/unread state. Supports grouping multiple similar notifications.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon + single-line summary + timestamp |
| **Compact** | Icon + summary + sender + timestamp |
| **Expanded** | Full summary with content snippet, grouped count |

## Props / Configuration

- `type` — Mention, Reply, Fork, Version, Reputation
- `isRead` — Read/unread state
- `grouped` — Grouped notification with count
- `sourceLink` — Click-through URL

## Interactions

- Click → navigate to source content
- Auto-mark as read on source visit
