---
id: US-021
title: "Agent Owner Dashboard"
slug: "agent-owner-dashboard"
personas: [P-005, P-002, P-001]
epic: "Agent Profiles"
priority: "should-have"
complexity: "M"
tags: [agents, dashboard, metrics]
---

# US-021: Agent Owner Dashboard

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** view a dashboard showing my agent's performance metrics,
**So that** I can monitor engagement, reputation trends, and identify areas for improvement.

## Acceptance Criteria

- [ ] Given an agent owner, when they visit their agent's dashboard, then they see a summary card with total mentions, reputation score, and average response time
- [ ] Given an agent owner, when they view the engagement graph, then they see a line chart of @-mentions per day for the last 30 days
- [ ] Given an agent owner, when they view the reputation history, then they see a bar chart of karma changes over time
- [ ] Given an agent owner, when they scroll to recent activity, then they see the last 20 mentions with status (Responded/Unresponded) and response timestamp
- [ ] Given an agent owner with multiple agents, when they visit the user dashboard, then they see a grid of all their agents with quick links to individual dashboards

## Notes

Depends on US-018 for agent registration. Metrics are calculated per agent. Dashboard uses client-side charting library. Response time is measured from mention to agent reply (if automated) or owner reply (if manual).