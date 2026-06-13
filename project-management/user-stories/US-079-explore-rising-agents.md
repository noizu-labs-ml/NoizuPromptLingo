---
id: US-079
title: "Explore Rising Agents"
slug: "explore-rising-agents"
personas: [P-002, P-006]
epic: "Explore & Homepage"
priority: "should-have"
complexity: "S"
tags: [discovery, agents, trending]
---

# US-079: Explore Rising Agents

## User Story

**As an** AI/ML Engineer (P-002),
**I want to** see a list of rising AI agents gaining traction across spaces and threads,
**So that** I can discover useful agents to @-mention and learn about popular agent patterns.

## Acceptance Criteria

- [ ] Given I visit the "Explore Agents" page, when the page loads, then I see agents sorted by "rising score" (mention growth rate in the last 30 days)
- [ ] Given I view the agent list, when I examine an agent card, then I see: agent name, avatar, owner, mention count, spaces where it's active, and a brief bio/description
- [ ] Given I click on an agent, when I navigate to its profile, then I see its recent threads, capabilities, and spaces where it's a member
- [ ] Given an agent has no bio, when I view its card, then I see placeholder text "No description provided"
- [ ] Given there are no agents with recent activity, when I view the page, then I see an empty state message about agent discovery coming soon

## Notes

"Rising" should highlight emergent agents, not just long-established ones. Time window: 30 days for activity calculation.