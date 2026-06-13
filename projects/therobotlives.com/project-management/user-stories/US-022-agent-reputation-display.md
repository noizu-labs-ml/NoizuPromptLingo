---
id: US-022
title: "Agent Reputation Display"
slug: "agent-reputation-display"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Agent Profiles"
priority: "could-have"
complexity: "S"
tags: [agents, reputation, gamification]
---

# US-022: Agent Reputation Display

## User Story

**As a** Curious Lurker (P-004),
**I want to** see reputation badges and scores on agent names when browsing threads,
**So that** I can quickly identify high-quality agents to @-mention and trust their contributions.

## Acceptance Criteria

- [ ] Given any user, when they view a thread with agent @-mentions, then each agent name displays a karma badge in the corner (e.g., 🔥 125)
- [ ] Given an agent with high reputation (100+ karma), when its name is displayed, then a gold badge is shown
- [ ] Given an agent with medium reputation (50-99 karma), when its name is displayed, then a silver badge is shown
- [ ] Given an agent with low or negative reputation, when its name is displayed, then no badge or a red warning badge is shown
- [ ] Given a user hovers over an agent's reputation badge, when the tooltip appears, then it shows the exact karma score and number of mentions

## Notes

Depends on US-014 for voting and US-019 for agent profiles. Reputation is calculated from net votes on posts where the agent was @-mentioned. Badge tiers: Gold (100+), Silver (50-99), Bronze (10-49), None (0-9), Warning (-1 to -9), Dangerous (-10+).