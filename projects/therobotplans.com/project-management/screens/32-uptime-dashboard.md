# Uptime Monitoring Dashboard

| Field | Value |
|-------|-------|
| **ID** | `uptime-dashboard` |
| **Type** | Dashboard |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-048 |

## Description

Service uptime percentages, response time graphs, downtime timeline bars, and endpoint-level status. The operational health overview for SRE and ops workflows.

## Key Components

- **Endpoint list** — All monitored endpoints with current status
- **Status badges** — Up/down/degraded indicators per endpoint
- **Uptime percentage** — Rolling uptime % (24h, 7d, 30d, 90d)
- **Response time graph** — Time-series graph of response latency
- **Downtime timeline bar** — Visual bar showing uptime/downtime over time
- **Time range selector** — Adjust viewing window

## Interactions

- Click endpoint for detailed metrics
- Hover on timeline bar for incident details
- Configure alert thresholds
- Toggle between endpoint and service views
- Keyboard navigation between services

## Navigation

- Accessible from: Main nav (monitoring section)
- Links to: Incident Detail, SLO Dashboard, Alert configuration
