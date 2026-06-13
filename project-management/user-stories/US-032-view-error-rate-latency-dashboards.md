---
id: US-032
title: "View error rate and latency dashboards"
slug: "view-error-rate-latency-dashboards"
personas: [P-002, P-004, P-005]
epic: "JustMCP Deployment"
priority: "should-have"
complexity: "M"
tags: [justmcp, monitoring, observability, errors]
---

# US-032: View Error Rate and Latency Dashboards

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** view error rate and latency dashboards for my deployed MCP servers,
**So that** I can diagnose performance issues and ensure my AI tool integrations are meeting SLA targets.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they navigate to the "Performance" tab, then the system displays error rate (percentage of failed invocations) and latency (p50, p95, p99) as time-series charts.
- [ ] Given the error rate chart is displayed, when the user hovers over a data point, then a tooltip shows the exact error count, error types breakdown (timeout, auth failure, policy denial, internal error), and the time window.
- [ ] Given the latency chart is displayed, when the user hovers over a data point, then a tooltip shows p50, p95, and p99 values with the invocation count for that window.
- [ ] Given the error rate exceeds a configurable threshold (default 5%), when the dashboard is open, then the system displays a visual warning banner with the current error rate and a link to error details.
- [ ] Given the p99 latency exceeds a configurable threshold (default 2 seconds), when the dashboard is open, then the system displays a visual warning banner with the current latency value.
- [ ] Given the user clicks on an error spike in the chart, when the drill-down loads, then it shows the individual failed invocations with error messages, caller IDs, and timestamps from the Audit Store.

## Notes

Thresholds should be configurable per-deployment. Error classification (timeout vs auth vs policy denial) is critical for actionable diagnosis. Related: US-031 (invocation metrics), US-029 (deployment status).
