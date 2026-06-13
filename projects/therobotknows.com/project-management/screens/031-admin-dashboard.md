# Admin Dashboard

| Field | Value |
|-------|-------|
| **ID** | admin-dashboard |
| **Type** | Dashboard |
| **Category** | Admin |
| **User Stories** | US-083, US-088 |

## Description

Platform operational dashboard for administrators.

## Key Components

- **KPI Tiles** — Total users, active universes, generations in 24h, error rate, avg generation latency (US-083)
- **Threshold Highlights** — Tiles highlight in amber/red when exceeding limits (US-083)
- **Sparkline Charts** — 7-day trend per metric (US-083)
- **Drill-down Links** — Navigate to detailed analytics (US-083)
- **Auto-refresh** — Metrics update every 60 seconds (US-083)
- **Navigation Sidebar** — Users, Billing, Analytics, Moderation, Rate Limits (US-083, US-088)
- **Access Denied** — 403 for non-admin users (US-083)

## Interactions

- Click tiles to view detailed analytics
- Alerts trigger when thresholds exceeded
- Data sourced from read replica or analytics table
- Real-time monitoring without full page reload
- Role-gated access at API and UI level

## Navigation

- Accessible from: /admin (admin only)
- Links to: Users, Billing, Analytics, Moderation, Rate Limiting