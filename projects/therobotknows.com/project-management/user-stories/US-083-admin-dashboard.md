---
id: US-083
title: "Admin Dashboard Overview"
slug: "admin-dashboard"
personas: [P-006]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "L"
tags: [admin, dashboard, analytics, operations, monitoring]
---

# US-083: Admin Dashboard Overview

## User Story

**As a** platform administrator (P-006),
**I want to** view a real-time operational dashboard showing key platform health metrics,
**So that** I can monitor system status, catch anomalies early, and make informed operational decisions.

## Acceptance Criteria

- [ ] Given I am logged in as an admin, when I navigate to /admin, then I see a dashboard with KPI tiles: total users, active universes, generations in the last 24h, error rate, and average generation latency.
- [ ] Given the dashboard is open, when a metric exceeds a configurable threshold (e.g., error rate > 1%), then the affected tile is highlighted in amber or red.
- [ ] Given I click a KPI tile, when the drill-down panel opens, then I see a 7-day sparkline chart and a link to the detailed analytics view.
- [ ] Given the dashboard is open, when I refresh or wait 60 seconds, then all metrics update automatically without a full page reload.
- [ ] Given I am not an admin, when I attempt to navigate to /admin/*, then I receive a 403 Forbidden response and am redirected to the home page.

## Notes

Admin access is role-gated at the API and UI level. Related: US-085 (usage analytics), US-088 (rate limiting). Dashboard data may be sourced from a read replica or analytics aggregation table to avoid load on the primary DB.
