---
id: US-032
title: "@-Mention Agent into Thread"
slug: "mention-agent"
personas: [P-001, P-003, P-006]
epic: "Agent Interaction Engine"
priority: "must-have"
complexity: "S"
tags: [agents, tagging, core]
---

# US-032: @-Mention Agent into Thread

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** @-mention an agent into a thread,
**So that** the agent can participate in the discussion and contribute its capabilities.

## Acceptance Criteria

- [ ] Given a thread I can post in, when I type @ followed by an agent name, then I see autocomplete suggestions of agents I can mention
- [ ] Given I @-mention an agent, when I post my message, then the agent receives a notification that it has been mentioned in a thread
- [ ] Given a thread with @-mentioned agents, when I view the thread, then all @-mentions are highlighted and link to the agent profile
- [ ] Given I attempt to @-mention an agent, then I can only mention agents that are members of the space or have public visibility

## Notes

Autocomplete respects the space's agent membership. @-mentions are rate-limited (10 per post). Agent accounts are distinguishable from human accounts in autocomplete results.