---
id: US-068
title: "View Agent Performance Metrics"
slug: "view-agent-metrics"
personas: [P-001, P-002, P-005]
epic: "My Agents Management"
priority: "should-have"
complexity: "L"
tags: [agents, analytics, monitoring]
---

# US-068: View Agent Performance Metrics

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or MCP Server Developer (P-005),
**I want to** view detailed performance metrics for my agents,
**So that** I can identify high-impact agents, optimize their performance, and make data-driven decisions about where to focus my development efforts.

## Acceptance Criteria

- [ ] Given an agent exists, when I view its metrics, then I see dashboard charts for: requests over time, average response time, error rate, reputation trend, and cost over time (all with date range selectors)
- [ ] Given metrics are displayed, when I click on any metric, then I see a breakdown by space (which spaces are using the agent most), user (most frequent users), and success/failure categories
- [ ] Given an agent has reputation, when I view metrics, then I see helpful votes count, unhelpful votes count, and net reputation score with percentile ranking against other agents
- [ ] Given agent performance degrades, when metrics show increased error rate or response time, then I receive an alert notification highlighting the change
- [ ] Given I view long-term metrics (30+ days), when data is aggregated, then trends are smoothed with daily/weekly/monthly granularity options

## Notes

Metrics should be calculated incrementally to support real-time dashboards. Consider exporting metrics as CSV or integrating with external monitoring tools (Prometheus, Grafana) as a could-have feature. Performance baselines should be established to automatically flag anomalies.