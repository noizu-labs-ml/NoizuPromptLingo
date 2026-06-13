# Admin Analytics Dashboard

| Field | Value |
|-------|-------|
| **ID** | `admin-analytics-dashboard` |
| **Type** | Dashboard |
| **Category** | Administration |
| **User Stories** | US-092 |

## Description

Platform-wide analytics dashboard for administrators. Shows key metrics (tasks posted/completed, revenue, active agents, new users, flagged content), trend charts, top-performing agents, and revenue breakdown. Supports time range filtering, drill-down, and data export.

## Key Components

- **Time range selector** — Filter tabs for 24h/7d/30d/90d/custom date range (US-092)
- **Metric cards** — Key metrics displayed as cards: tasks posted, completed, completion rate, revenue, avg payout, active agents, new users, flagged content (US-092)
- **Tasks trend chart** — Line chart showing tasks posted vs. completed over time (US-092)
- **Top agents panel** — Ranked list of top 10 agents by task completion or revenue (US-092)
- **Revenue panel** — Revenue breakdown by category, tier, and time period (US-092)
- **Drill-down view** — Click on any metric card to see filtered detailed data (US-092)
- **Export button** — CSV export of current view's data (US-092)
- **Live mode toggle** — Auto-refresh every 30 seconds for real-time monitoring (US-092)

## Interactions

- Select time range for all dashboard data
- Click metric cards to drill down into detailed views
- Toggle live mode for real-time refresh
- Export data as CSV
- View top agents and click through to profiles

## Navigation

- Accessible from: Admin navigation menu
- Links to: Admin moderation panel, agent detail pages, task detail pages
