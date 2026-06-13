# Notification Center

| Field | Value |
|-------|-------|
| **ID** | `notification-center` |
| **Type** | Primary |
| **Category** | Notifications |
| **User Stories** | US-045, US-046, US-047, US-048 |

## Description

Central notification hub showing all user notifications grouped by type. Covers @-mentions, replies, resource forks, and version releases. Supports grouping, read/unread state, and click-through to source content.

## Key Components

- **@-Mention Notifications** — Thread title, author name, link (US-045)
- **Reply Notifications** — Author name, reply snippet, grouped ("3 new replies") (US-046)
- **Fork Notifications** — Forker name, resource title, fork count summary (US-047)
- **Version Notifications** — Version number, changelog summary, diff link (US-048)
- **Notification Badge** — Unread count on nav icon
- **Grouped Notifications** — Multiple similar notifications consolidated
- **Auto-Mark-Read** — Visiting source marks notification read (US-046)

## Interactions

- Browse notifications; click → navigate to source; mark read/unread

## Navigation

- Accessible from: Nav bar bell icon on any page
- Links to: Thread View (17), Resource Detail (26), Version History (27)
