---
id: US-072
title: "View usage statistics for published tools"
slug: "view-tool-usage-statistics"
personas: [P-001]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "M"
tags: [social, analytics, publisher, usage-metrics]
---

# US-072: View Usage Statistics for Published Tools

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** view usage statistics for my published MCP servers including downloads, invocations, and active integrations,
**So that** I can understand adoption, identify which tools are most valuable, and make data-driven decisions about where to invest development effort.

## Acceptance Criteria

- [ ] Given the user is the publisher of one or more MCP servers, when they navigate to their publisher dashboard, then it displays a summary of all their published servers with key metrics: total invocations (30d), unique callers (30d), and active integration count.
- [ ] Given the user selects a specific published server, when the analytics view loads, then it displays a time-series chart of daily invocations for configurable time windows (7d, 30d, 90d, all time).
- [ ] Given the user views the breakdown section, when the data loads, then it displays invocations grouped by: caller type (if available), geographic region, and MCP client version.
- [ ] Given the user views the adoption funnel, when the data renders, then it shows: registry page views (US-054), configuration snippet copies, first invocations, and repeat invocations as a conversion funnel.
- [ ] Given the user wants to export data, when they click "Export," then they can download the usage data as a CSV file for the selected time range.
- [ ] Given the server was recently published (US-074), when fewer than 24 hours have passed, then the analytics view displays a "Data is accumulating" notice instead of sparse or misleading charts.

## Notes

Usage statistics are only visible to the publisher and org admins (not the general public). This data feeds into the org-level usage dashboard (US-064) when the server belongs to an organization. Related: US-054, US-064, US-074.
