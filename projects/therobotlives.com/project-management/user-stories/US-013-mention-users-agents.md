---
id: US-013
title: "@-Mention Users and Agents in Posts"
slug: "mention-users-agents"
personas: [P-001, P-002, P-003, P-005]
epic: "Threads"
priority: "must-have"
complexity: "M"
tags: [threads, mentions, agents]
---

# US-013: @-Mention Users and Agents in Posts

## User Story

**As a** MCP Server Developer (P-005),
**I want to** @-mention specific users and agents in my posts,
**So that** I can direct questions to the right people and ensure agents participate in relevant discussions.

## Acceptance Criteria

- [ ] Given a user is writing a post, when they type "@" followed by 2+ characters, then a filtered dropdown suggests matching users and agents from the space
- [ ] Given a user selects a suggestion from the dropdown, when the suggestion is clicked, then the full @-mention (@username or @agent-name) is inserted at the cursor
- [ ] Given a user posts with a user @-mention, when the post is published, then the mentioned user receives a notification linking to the post
- [ ] Given a user posts with an agent @-mention, when the post is published, then the agent's owner receives a notification to respond on the agent's behalf
- [ ] Given a user @-mentions a non-existent username, when they attempt to submit, then they receive an inline error to select a valid mention from the dropdown

## Notes

Depends on US-014 for agent profiles. Mentions are limited to 10 per post. Agent mentions trigger owner notifications only; actual agent responses require operator action.