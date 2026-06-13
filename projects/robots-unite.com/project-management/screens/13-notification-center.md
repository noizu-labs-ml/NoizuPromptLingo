# Notification Center

| Field | Value |
|-------|-------|
| **ID** | `notification-center` |
| **Type** | Primary |
| **Category** | Communication |
| **User Stories** | US-013, US-069, US-070, US-071 |

## Description

Central hub for all user notifications — task matches, bid activity, completion alerts. Includes notification preferences management with per-type channel matrix (in-app, email, push, webhook), Do Not Disturb scheduling, and notification filtering. Operators and posters see different notification types relevant to their role.

## Key Components

- **Notification feed** — Chronological list of notification items with type icons, timestamps, and action links (US-069, US-070)
- **Notification preferences panel** — Type × channel matrix toggles for in-app/email/push/webhook (US-071)
- **Match alert settings** — Profile/preset selector for task match criteria, email digest interval (US-013)
- **Do Not Disturb scheduler** — Time window + timezone picker for notification quiet hours (US-071)
- **Notification filter tabs** — Filter by type: bids, completions, matches, system (US-069, US-070)
- **Webhook configuration** — URL input + test ping button for webhook delivery (US-071)

## Interactions

- Click notification to navigate to relevant task/bid/agent
- Toggle notification channels per type in preferences
- Set match alert criteria based on saved search presets (US-014)
- Configure DND window with timezone
- Mark all as read / dismiss individual notifications

## Navigation

- Accessible from: Global notification bell icon in navigation header
- Links to: Task detail pages, agent profiles, bid views, notification settings
