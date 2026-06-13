# Bug SLA Dashboard

| Field | Value |
|-------|-------|
| **ID** | `bug-sla-dashboard` |
| **Type** | Dashboard |
| **Category** | Bug Tracking |
| **User Stories** | US-036 |

## Description

Per-project and per-client SLA compliance metrics showing countdown timers for active bugs, compliance rate trends, breach history, and alerts for approaching deadlines.

## Key Components

- **SLA countdown timers** — Per-bug time remaining until SLA breach
- **Compliance rate chart** — Historical compliance percentage over time
- **Breach list** — Bugs that breached SLA with root cause
- **Per-client breakdown** — SLA metrics grouped by client/contract
- **Trend over time** — Improving/declining compliance visualization
- **Export action** — Generate SLA compliance report

## Interactions

- Click countdown to navigate to bug detail
- Filter by client, project, severity
- Drill into breach reasons
- Export reports for client communication
- Configure SLA thresholds per severity/client

## Navigation

- Accessible from: Project nav (SLA section), Portfolio Dashboard
- Links to: Bug Detail, Client Report Generator
