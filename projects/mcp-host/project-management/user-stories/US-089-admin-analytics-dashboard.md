---
id: US-089
title: "Platform admin views platform-wide analytics dashboard"
slug: "admin-analytics-dashboard"
personas: [P-005, P-006]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "L"
tags: [admin, analytics, dashboard, metrics, platform-health]
---

# US-089: Platform Admin Views Platform-Wide Analytics Dashboard

## User Story

**As an** Engineering Manager (P-005),
**I want to** view a platform-wide analytics dashboard showing aggregate metrics across all hosted MCP servers,
**So that** I can monitor platform health, identify trends in usage and errors, and make data-driven decisions about capacity planning and feature prioritization.

## Acceptance Criteria

- [ ] Given a platform admin navigates to the Admin Analytics dashboard, when the page loads, then it displays key aggregate metrics: total active servers, total invocations (24h/7d/30d), average latency p50/p95/p99, error rate percentage, and resource utilization across the fleet
- [ ] Given the analytics dashboard is displayed, when the admin selects a time range (last hour, 24 hours, 7 days, 30 days, custom), then all charts and metrics update to reflect the selected time range
- [ ] Given the analytics dashboard shows an elevated error rate or latency spike, when the admin clicks on the anomaly, then a drill-down view shows the affected servers ranked by error count or latency contribution
- [ ] Given the analytics dashboard is displayed, when the admin exports the data, then a CSV or JSON file is generated containing the visible metrics with per-server breakdowns

## Notes

The dashboard should support filtering by organization, server status (active/suspended/healthy/unhealthy), and surface (JustMCP.it, MCP Jumpstart, SafeMCP). For self-hosted deployments, this is scoped to the organization's servers. Data should refresh at most every 60 seconds for real-time views. Related to US-089's fleet-level visibility from the persona scenarios.
