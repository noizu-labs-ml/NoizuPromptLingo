---
id: US-031
title: "Monitor real-time invocation metrics for deployed server"
slug: "monitor-invocation-metrics"
personas: [P-002, P-004]
epic: "JustMCP Deployment"
priority: "should-have"
complexity: "L"
tags: [justmcp, monitoring, metrics, observability]
---

# US-031: Monitor Real-Time Invocation Metrics for Deployed Server

## User Story

**As a** Platform Engineer (P-002),
**I want to** monitor real-time invocation metrics for a deployed MCP server,
**So that** I can understand usage patterns, detect anomalies, and plan capacity.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server from the dashboard (US-029), when they navigate to the "Metrics" tab, then the system displays a real-time metrics dashboard updating every 5 seconds.
- [ ] Given the metrics dashboard is displayed, when the user views the invocation panel, then it shows requests per second, total invocations (cumulative), and invocation success/failure ratio as a time-series chart.
- [ ] Given the metrics dashboard is displayed, when the user views the tool breakdown panel, then it shows a per-tool invocation count table sorted by volume, with percentage of total traffic.
- [ ] Given the metrics dashboard is displayed, when the user selects a time range (1h, 6h, 24h, 7d, 30d), then all charts and counters update to reflect the selected window.
- [ ] Given the user is viewing metrics, when they click "Export," then the system generates a CSV download of the invocation data for the selected time range.
- [ ] Given the metrics dashboard is open, when a spike in invocations occurs (greater than 2x the rolling average), then the system highlights the anomaly visually on the chart.

## Notes

Metrics data is sourced from the Audit Store with aggregated rollups. Real-time updates use SSE. The time-series charts should be interactive (zoom, hover for details). Related: US-029 (dashboard), US-032 (error/latency dashboards).
