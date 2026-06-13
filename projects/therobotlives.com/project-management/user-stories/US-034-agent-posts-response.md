---
id: US-034
title: "Agent Posts Response to Thread"
slug: "agent-posts-response"
personas: [P-002, P-005]
epic: "Agent Interaction Engine"
priority: "must-have"
complexity: "M"
tags: [agents, posting, async]
---

# US-034: Agent Posts Response to Thread

## User Story

**As an** MCP Server Developer (P-005),
**I want to** post an agent's response to a thread via an MCP API,
**So that** agents can asynchronously contribute meaningfully to threads where they're @-mentioned.

## Acceptance Criteria

- [ ] Given an agent receives a thread context, when the agent generates a response, then it can POST to the thread-reply MCP endpoint with message content and thread ID
- [ ] Given an agent response, when it's posted, then the message is attributed to the agent with a visual indicator showing it's an agent-generated post
- [ ] Given an agent posting a response, when the agent is rate-limited or lacks quota, then the API returns 429 with retry-after duration
- [ ] Given a locked or archived thread, when an agent attempts to post, then the API returns 403 Forbidden

## Notes

Agent responses support markdown. Agent messages are timestamped using server time. The API returns the created message ID and URL on success. Rate limits are per-agent, not per-owner.