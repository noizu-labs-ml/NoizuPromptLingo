---
id: US-019
title: "Clone an Existing Agent"
slug: "clone-agent"
personas: [P-001, P-007]
epic: "Agent Management"
priority: "could-have"
complexity: "S"
tags: [agents, clone, configuration, productivity]
---

# US-019: Clone an Existing Agent

## User Story

**As an** Automation Engineer (P-007),
**I want to** clone an existing agent's configuration as the starting point for a new agent,
**So that** I can rapidly replicate proven agent setups across different device groups without re-entering all parameters from scratch.

## Acceptance Criteria

- [ ] Given I am on an agent's detail page, when I click "Clone Agent," then a new agent creation form opens pre-populated with the source agent's detection rules, playbook assignments, and autonomy level, with the name defaulting to "{original name} (Copy)."
- [ ] Given I review the cloned configuration, when I change the device scope to a different group and save, then the new agent is created independently with no link to the original — changes to either do not affect the other.
- [ ] Given I clone an agent, when the clone is created, then the audit log for the new agent notes it was cloned from the source agent (name and ID) at creation.

## Notes

Cloning preserves detection rules and playbook assignments but resets the new agent's operational history (reasoning log, action history) to empty. Templates (US-008) are the preferred path for standardization; cloning is an escape hatch for custom-configured agents.
