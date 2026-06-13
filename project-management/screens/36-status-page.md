# Public Status Page

| Field | Value |
|-------|-------|
| **ID** | `status-page` |
| **Type** | Primary |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-053 |

## Description

Auto-generated public or internal status page showing per-service status, active incident banners with AI-drafted summaries, 90-day uptime history, and subscriber notifications.

## Key Components

- **Service status list** — All services with current status (operational, degraded, down)
- **Active incident banner** — Highlighted current incidents with summary
- **Agent-drafted summary** — AI-written incident communication (editable)
- **90-day history** — Per-service uptime bar for the past 90 days
- **Subscriber signup** — Email/webhook notification signup
- **Branding config** — Custom branding for the status page

## Interactions

- Auto-updates when incidents are created/resolved
- Agent drafts customer-facing summaries (team edits before publish)
- Subscribers notified on status changes
- Admin view for editing content and branding
- Embeddable widget for external sites

## Navigation

- Accessible from: Public URL, Monitoring nav (admin)
- Links to: Incident Detail (admin), Subscriber management (admin)
