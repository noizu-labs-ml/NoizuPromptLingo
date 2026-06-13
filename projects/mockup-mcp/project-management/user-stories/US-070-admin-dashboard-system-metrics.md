---
id: US-070
title: "Admin dashboard with system metrics"
slug: "admin-dashboard-system-metrics"
personas: [P-004, P-005]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, dashboard, metrics, observability, ops]
---

# US-070: Admin Dashboard with System Metrics

## User Story

**As a** Startup Founder (P-004),
**I want to** view a real-time admin dashboard showing generation volume, active users, error rates, and queue depth,
**So that** I can monitor system health and usage trends without connecting to infrastructure tooling.

## Acceptance Criteria

- [ ] Given I am logged in as an admin, when I navigate to `/admin`, then a dashboard displays: total generations (24h, 7d, 30d), active users, API error rate, and current generation queue depth
- [ ] Given the dashboard is open, when data is refreshed (auto or manual), then metrics update without a full page reload
- [ ] Given a metric exceeds a warning threshold (e.g., error rate > 5%), when displayed, then the metric is visually highlighted in a warning state
- [ ] Given I am not an admin, when I attempt to access `/admin`, then I am redirected with a 403 response

## Notes

Dashboard data is served from the Phoenix backend's telemetry aggregation layer. Real-time updates via Phoenix LiveView or polling at 30-second intervals. Access control must be enforced server-side, not just client-side.
