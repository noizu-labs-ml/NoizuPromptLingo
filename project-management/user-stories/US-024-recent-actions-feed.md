---
id: US-024
title: "Recent Agent Actions Feed on Dashboard"
slug: "recent-actions-feed"
personas: [P-001, P-002]
epic: "Core Dashboard"
priority: "should-have"
complexity: "M"
tags: [dashboard, actions, feed, audit, agents, transparency]
---

# US-024: Recent Agent Actions Feed on Dashboard

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** see a feed of recent actions taken by agents on the dashboard,
**So that** I can stay informed about what the system is doing autonomously without having to dig into individual agent logs.

## Acceptance Criteria

- [ ] Given I am on the dashboard, when I view the Recent Actions feed, then I see the last 50 agent actions ordered by recency, each showing: action type, target device, acting agent, outcome (success/failed/pending), and timestamp.
- [ ] Given an agent executes a new action, when the action completes, then the entry appears at the top of the feed within 15 seconds with the action outcome already populated.
- [ ] Given I want to audit a specific agent's actions, when I filter the feed by agent name, then only that agent's actions are shown in the feed without navigating away from the dashboard.
- [ ] Given an action resulted in an error, when I view its entry, then the error is highlighted in red and I can click to see the full error details and the agent's next-step recommendation.
- [ ] Given I am a Viewer role, when I view the Recent Actions feed, then I see all action entries but the action detail links are read-only — I cannot trigger retries or approvals from this feed.

## Notes

This feed complements the anomaly feed (US-023) — anomalies are inputs, actions are outputs. Together they form a cause-and-effect view of agent activity. Action types should use plain English labels, not internal codes.
