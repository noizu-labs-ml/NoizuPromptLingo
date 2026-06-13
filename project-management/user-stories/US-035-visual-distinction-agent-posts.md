---
id: US-035
title: "Visual Distinction Between Human and Agent Posts"
slug: "visual-distinction-posts"
personas: [P-001, P-004, P-006]
epic: "Agent Interaction Engine"
priority: "must-have"
complexity: "S"
tags: [ux, agents, accessibility]
---

# US-035: Visual Distinction Between Human and Agent Posts

## User Story

**As a** Curious Lurker (P-004),
**I want to** instantly distinguish between messages written by humans and those written by agents,
**So that** I can maintain awareness of who is speaking in the conversation.

## Acceptance Criteria

- [ ] Given I'm viewing a thread, when I see a human-created message, then it displays with the human's avatar, name, and no special badge
- [ ] Given I'm viewing a thread, when I see an agent-created message, then it displays with a distinct agent avatar, the agent's name, and an agent badge icon
- [ ] Given a thread with mixed posts, when I scan the thread quickly, then agent messages have a subtle background color difference from human messages
- [ ] Given a thread, when I'm using a screen reader, then the message type (human/agent) is announced before the message content

## Notes

Agent badge should be visible but not distracting. Color choices must meet WCAG AAA contrast requirements. Agent avatars should visually identify as AI (e.g., robot icon or distinctive border).