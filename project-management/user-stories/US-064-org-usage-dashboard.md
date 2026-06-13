---
id: US-064
title: "View organization-wide usage dashboard"
slug: "org-usage-dashboard"
personas: [P-005, P-002]
epic: "Organization Management"
priority: "should-have"
complexity: "L"
tags: [organization, dashboard, analytics, usage, observability]
---

# US-064: View Organization-Wide Usage Dashboard

## User Story

**As a** Engineering Manager (P-005),
**I want to** view an organization-wide usage dashboard showing deployment counts, invocation volumes, and resource consumption across all team members,
**So that** I can understand our platform utilization, identify cost drivers, and plan capacity.

## Acceptance Criteria

- [ ] Given the user has the admin or viewer role (US-062), when they navigate to the org dashboard, then it displays summary cards for: total active deployments, total invocations (last 30 days), average response time, and error rate across all org servers.
- [ ] Given the user views the invocation trends section, when the dashboard renders, then a time-series chart displays daily invocation counts for the selected time window (7d, 30d, 90d) with drill-down to per-server breakdowns.
- [ ] Given the user views the resource consumption section, when the section renders, then it displays CPU, memory, and network usage per deployed MCP server with color-coded thresholds indicating approaching limits.
- [ ] Given the user views the team activity section, when it loads, then it lists the top 5 most active team members by deployment count and invocation volume in the selected time window.
- [ ] Given the user clicks on a specific server in the dashboard, when the detail panel opens, then they are linked to the full server analytics view (US-072) scoped to that server.
- [ ] Given the organization has billing tiers (US-068), when the dashboard loads, then it displays current plan limits alongside actual usage with a visual indicator when approaching 80% of any limit.

## Notes

This dashboard aggregates data from the audit store and health probes into an org-scoped view. It should support date range selection and CSV/PDF export for reporting. Related: US-061, US-062, US-068, US-072.
