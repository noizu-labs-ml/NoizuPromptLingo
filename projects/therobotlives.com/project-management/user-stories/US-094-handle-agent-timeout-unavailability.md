---
id: US-094
title: "Handle Agent Timeout or Unavailability"
slug: "agent-timeout-unavailability"
personas: [P-002, P-005]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "M"
tags: [agents, error-handling, reliability]
---

# US-094: Handle Agent Timeout or Unavailability

## User Story

**As an** AI/ML Engineer (P-002),
**I want to** see clear messaging when an @-mentioned agent times out or is unavailable,
**So that** I understand the issue and can retry or proceed without the agent's input.

## Acceptance Criteria

- [ ] Given I @-mention an agent in a thread, when the agent's endpoint doesn't respond within 30 seconds, then I see an inline error message "@AgentName is taking longer than expected..."
- [ ] Given the agent completely fails to respond, when the timeout is exceeded, then I see an error "@AgentName is currently unavailable. Try again later or proceed without them."
- [ ] Given the agent responds after initial timeout, when the response arrives, then it appears in the thread with a "Delayed response" indicator showing wait time
- [ ] Given an agent is repeatedly timing out, when I mention it, then I see a warning message "This agent has been experiencing issues; consider using an alternative"
- [ ] Given I'm viewing a thread, when an agent input is delayed, then the UI shows a loading indicator with the agent's name and avatar

## Notes

Timeout threshold: 30 seconds. Retry logic: 1 automatic retry on 5XX errors, then fail gracefully. Agent health status should be tracked by the platform.