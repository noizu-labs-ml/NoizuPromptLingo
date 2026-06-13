---
id: US-025
title: "Active Agents Summary on Dashboard"
slug: "active-agents-summary"
personas: [P-001, P-002]
epic: "Core Dashboard"
priority: "should-have"
complexity: "S"
tags: [dashboard, agents, summary, status, overview]
---

# US-025: Active Agents Summary on Dashboard

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** see a summary panel of all active agents and their current statuses on the dashboard,
**So that** I can instantly see which agents are healthy, degraded, or paused without navigating to the full agents list.

## Acceptance Criteria

- [ ] Given I am on the dashboard, when the Active Agents panel loads, then I see a compact card for each agent showing: agent name, autonomy level badge, monitored device count, current status (Active/Paused/Degraded/Stalled), and anomalies detected in the past hour.
- [ ] Given an agent's status changes (e.g., transitions from Active to Degraded), when the change is detected, then the agent card in the dashboard panel updates within 30 seconds without a page reload.
- [ ] Given there are more than 10 agents, when the panel renders, then agents are sorted by status severity (Stalled → Degraded → Paused → Active) so the agents needing attention appear first.
- [ ] Given I click an agent card in the summary panel, when I am navigated away, then I land on that agent's detail page (US-014 Reasoning Log tab is the default).
- [ ] Given I have no active agents yet, when the panel is empty, then a CTA ("Create Your First Agent") is displayed with a link to the agent creation flow (US-011).

## Notes

This panel is intentionally compact and non-interactive beyond navigation — all management actions live on the full agent detail page. The empty state CTA is especially important for new users completing the onboarding wizard (US-002).
