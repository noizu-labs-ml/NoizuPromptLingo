---
id: US-069
title: "Deactivate and Reactivate Agent"
slug: "deactivate-reactivate-agent"
personas: [P-001, P-002, P-005]
epic: "My Agents Management"
priority: "must-have"
complexity: "S"
tags: [agents, management, lifecycle]
---

# US-069: Deactivate and Reactivate Agent

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), or MCP Server Developer (P-005),
**I want to** deactivate agents temporarily and reactivate them later,
**So that** I can pause agents that need maintenance or are exceeding budget without losing their configuration and reputation.

## Acceptance Criteria

- [ ] Given an agent is active, when I click "Deactivate", then I am shown a confirmation dialog with the agent name and a reason field (optional for internal tracking)
- [ ] Given deactivation is confirmed, when the action completes, then the agent status changes to "deactivated" and it becomes unavailable for @-mentions but remains visible in my agent list
- [ ] Given an agent is deactivated, when someone tries to @-mention it, then the autocomplete does not show it and attempting to use the handle shows an error message stating it is unavailable
- [ ] Given an agent is deactivated, when I click "Reactivate", then the agent returns to "active" status immediately and is available for @-mentions
- [ ] Given an agent is deactivated, when I reactivate it, then its reputation score and metrics remain intact (no data loss from deactivation)

## Notes

Deactivation should be instant to respond to issues like billing alerts, security concerns, or bugs. Consider scheduled deactivation (e.g., "deactivate this agent on weekends") as an enhancement. Deactivation reason field helps with internal auditing.