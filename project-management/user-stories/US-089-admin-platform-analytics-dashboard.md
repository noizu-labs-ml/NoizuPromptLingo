---
id: US-089
title: "Admin: View Platform Analytics Dashboard"
slug: "admin-platform-analytics-dashboard"
personas: [P-001]
epic: "Settings & Administration"
priority: "could-have"
complexity: "L"
tags: [admin, analytics, dashboard, metrics, reporting]
---

# US-089: Admin: View Platform Analytics Dashboard

## User Story

**As a** platform administrator tracking growth and engagement (P-001 acting as admin),
**I want to** view a consolidated analytics dashboard showing user activity, catalog engagement, scan volume, and content metrics,
**So that** I can make informed decisions about product priorities, capacity planning, and community health.

## Acceptance Criteria

- [ ] Given the admin analytics dashboard, when I view it, then I see KPI cards for: total registered users, active users (7d/30d), techniques in catalog, scans run this month, and community submissions pending review
- [ ] Given time-series charts, when I select a date range, then the charts update to show new registrations, scan volume, API calls, and technique page views over that period
- [ ] Given catalog engagement metrics, when I view them, then I can see the top 10 most-viewed techniques, most-bookmarked, and most-referenced in scan reports
- [ ] Given user cohort data, when I view it, then I can see breakdown by plan tier, by persona type (if self-reported), and by acquisition source
- [ ] Given the dashboard, when I export data, then I can download a CSV of any chart's underlying data for a selected period
- [ ] Given anomalous activity (e.g., spike in failed scan attempts, unusual API call patterns), when thresholds are exceeded, then an alert banner appears on the dashboard

## Notes

Analytics data must be anonymized and aggregated — no PII in chart data. Dashboard should load within 3 seconds using pre-aggregated snapshots rather than live queries. Accessible to `admin` role users only; no self-service analytics for org admins in this iteration.
