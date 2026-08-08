# Org Dashboard

| Field | Value |
|-------|-------|
| **ID** | `org-dashboard` |
| **Type** | Dashboard |
| **Category** | Core Work |
| **User Stories** | US-092 |

## Description

Landing page for an organization at `/app/[orgId]`, summarizing active sessions, tickets, and recent activity across the org. Announces state changes to assistive technology so screen-reader users track updates without re-scanning the page.

## Key Components

- **Org Activity Summary Cards** — session/ticket/chat counts at a glance
- **Recent Activity Timeline** — cross-entity feed of recent changes
- **Quick Links Panel** — shortcuts into Projects, Sessions, Tickets, Chat
- **Live Region Announcer** — announces dashboard state changes to screen readers (US-092)

## Interactions

- Dashboard data refreshes in the background; changed summary values trigger a Live Region Announcer update (US-092)
- User clicks a Quick Links Panel entry → routes to the corresponding list screen

## Navigation

- Accessible from: Organization Picker (06), app-shell org context on every authenticated screen
- Links to: Projects List (18), Sessions List (20), Tickets List (25), Chat Room List (22)
