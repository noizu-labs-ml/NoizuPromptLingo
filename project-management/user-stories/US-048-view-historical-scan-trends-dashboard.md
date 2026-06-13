---
id: US-048
title: "View historical scan trends dashboard"
slug: "view-historical-scan-trends-dashboard"
personas: [P-002, P-005]
epic: "Defender — Results & Reporting"
priority: "could-have"
complexity: "L"
tags: [defender, results, trends, dashboard, analytics, history]
---

# US-048: View Historical Scan Trends Dashboard

## User Story

**As a** CISO at a mid-market SaaS company (P-005),
**I want to** view a dashboard showing security posture trends across all scans over time,
**So that** I can demonstrate continuous improvement to the board, identify endpoints with consistently high vulnerability rates, and track the effect of our mitigation investments.

## Acceptance Criteria

- [ ] Given I navigate to the Trends dashboard, when it loads, then I see a time-series chart of finding counts by severity for all scans across a selectable time range (7d, 30d, 90d, custom).
- [ ] Given multiple endpoints have been scanned, when I view the dashboard, then I can filter by endpoint, technique category, or scan template to isolate trend lines.
- [ ] Given scans have varying technique scope over time, when I view trends, then a note warns that scope changes affect comparability and flags periods where scope changed significantly.
- [ ] Given I want to track a single endpoint, when I navigate to the endpoint detail, then I see its scan history timeline with each run's severity distribution visualized as a stacked bar.
- [ ] Given I want to export trend data, when I click "Export CSV", then I receive a CSV with one row per scan containing date, endpoint, finding counts by severity, and pass/fail verdict.

## Notes

Dashboard requires a meaningful scan history to be useful — at least 3 scans for trend visualization. Depends on scan comparison model from US-043. Endpoint normalization (grouping scans by logical endpoint vs. exact URL) needs product decision before implementation.
