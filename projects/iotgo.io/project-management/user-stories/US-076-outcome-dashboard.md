---
id: US-076
title: "Outcome Dashboard"
slug: "outcome-dashboard"
personas: [P-002, P-001]
epic: "Insights & Reporting"
priority: "must-have"
complexity: "L"
tags: [dashboard, reporting, agent-performance, outcomes]
---

# US-076: Outcome Dashboard

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** view a consolidated outcome dashboard showing agent performance, success rates, and escalation rates across my fleet,
**So that** I can quickly assess the value AI agents are delivering and identify areas needing attention.

## Acceptance Criteria

- [ ] Given I am on the Outcome Dashboard, when the page loads, then I see summary cards for total incidents handled, agent success rate (%), and escalation rate (%) for the selected time period
- [ ] Given the dashboard is displayed, when I select a time range (24h, 7d, 30d, 90d), then all metrics and charts update to reflect that period
- [ ] Given multiple agents are deployed, when I view the dashboard, then a breakdown by agent type and fleet group is shown alongside the aggregate view
- [ ] Given an agent escalated an incident, when I click the escalation rate metric, then I am taken to a filtered incident list showing escalated events
- [ ] Given the dashboard has loaded data, when I hover over a trend chart point, then a tooltip shows exact values and a timestamp

## Notes

This is the primary landing page for operations personas. Relates to US-077 (cost impact) and US-079 (agent performance comparison). Success rate is defined as incidents resolved without human escalation divided by total incidents handled.
