---
id: US-079
title: "Agent Performance Comparison"
slug: "agent-performance-comparison"
personas: [P-001, P-006]
epic: "Insights & Reporting"
priority: "should-have"
complexity: "M"
tags: [agent, performance, comparison, analytics]
---

# US-079: Agent Performance Comparison

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** compare performance metrics across individual agents side by side,
**So that** I can identify high-performing agents to replicate their configurations and low-performers to tune or replace.

## Acceptance Criteria

- [ ] Given multiple agents are deployed, when I navigate to Agent Comparison, then I can select up to 5 agents and view their metrics (success rate, avg response time, escalation rate, playbooks executed) in a side-by-side table
- [ ] Given agents are compared, when I click any agent's name in the comparison table, then I navigate to that agent's detailed profile page
- [ ] Given I select agents of different types (anomaly detection vs. remediation), then the comparison table shows only metrics applicable to both types, with type-specific metrics in expandable rows
- [ ] Given I want to share findings, when I click Copy Link, then a shareable URL encoding the current agent selection and time range is copied to my clipboard

## Notes

Relates to US-076 (outcome dashboard) and US-083 (fleet optimization recommendations). This view is primarily used by technical personas during performance tuning cycles.
