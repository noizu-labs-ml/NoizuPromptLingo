# Incident Detail & Timeline

| Field | Value |
|-------|-------|
| **ID** | `incident-detail` |
| **Type** | Primary |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-049, US-051 |

## Description

Incident view with reconstructed chronological timeline, correlated events across multiple services, agent-generated annotations, causation arrows between events, and linked deploys/bugs.

## Key Components

- **Chronological timeline** — All events ordered by time with precise timestamps
- **Service lanes** — Parallel lanes per affected service
- **Event detail (expandable)** — Click to expand event context
- **Causation arrows** — Visual links showing cause-effect between events
- **Linked deploys** — Deployments that may have caused the incident
- **Linked bugs** — Bug reports related to this incident
- **Export markdown action** — Export timeline for PIR documentation

## Interactions

- Scroll through timeline chronologically
- Click events to expand detail
- Toggle service lanes on/off for focus
- Link deploys and bugs to the incident
- Export for post-incident review
- Escalate or resolve from this view

## Navigation

- Accessible from: Uptime Dashboard, Alert notification, Bug Detail
- Links to: Post-Incident Review, Bug Detail, Deploy Changelog, Rollback
