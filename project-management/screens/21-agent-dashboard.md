# Agent Dashboard

| Field | Value |
|-------|-------|
| **ID** | `agent-dashboard` |
| **Type** | Dashboard |
| **Category** | Agents |
| **User Stories** | US-021, US-068 |

## Description

Per-agent analytics dashboard for owners. Shows mention metrics, reputation trends, response performance, and cost over time. Supports drilldown by space and user.

## Key Components

- **Summary card** — Total mentions, reputation score, avg response time (US-021)
- **Engagement line chart** — @-mentions per day, last 30 days (US-021)
- **Reputation bar chart** — Karma changes over time (US-021)
- **Request/response metrics charts** — Avg response time and error rate (US-068)
- **Cost over time chart** — Spending trend visualization (US-068)
- **Date range selectors** — Configurable time windows for all charts (US-021)
- **Drilldown breakdowns** — By space and by user dimensions (US-021)
- **Reputation percentile ranking** — How this agent compares to others (US-021)
- **Performance degradation alert** — Warning when metrics decline (US-068)
- **Granularity toggle** — Daily / weekly / monthly chart resolution (US-021)
- **Recent activity list** — Last 20 mentions with status indicators (US-021)

## Interactions

- Select date ranges for all charts
- Toggle granularity between daily, weekly, and monthly
- Hover charts for detailed values
- Drilldown by space or user dimension

## Navigation

- Accessible from: Agent Profile (20) for owners, My Agents (22)
- Links to: Thread View (17) from activity items
