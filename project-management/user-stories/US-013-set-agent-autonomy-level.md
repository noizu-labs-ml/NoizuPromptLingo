---
id: US-013
title: "Set Agent Autonomy Level"
slug: "set-agent-autonomy-level"
personas: [P-001, P-002]
epic: "Agent Management"
priority: "must-have"
complexity: "M"
tags: [agents, autonomy, safety, configuration, progressive-autonomy]
---

# US-013: Set Agent Autonomy Level

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** set and change the autonomy level of an agent on a scale of 0 to 4,
**So that** I can precisely control how much independent decision-making the agent exercises versus requiring human approval.

## Acceptance Criteria

- [ ] Given I am on an agent's configuration page, when I view the autonomy level control, then I see all five levels (0: Observe, 1: Notify, 2: Suggest, 3: Act with Approval, 4: Fully Autonomous) with plain-language descriptions of what each level enables.
- [ ] Given I change the autonomy level, when I save, then the change takes effect for all subsequent agent decisions and the prior level is recorded in the audit log with the changing user's identity and timestamp.
- [ ] Given an agent is at Level 3 or 4, when I attempt to increase it further (or set a new agent to Level 4), then a confirmation modal appears requiring me to type the agent name to confirm, with a clear warning about autonomous action scope.
- [ ] Given an agent is at Level 4, when it executes a remediation action autonomously, then the action is logged with the agent's reasoning summary and I receive a notification within 60 seconds.
- [ ] Given I am an Operator role (not Admin), when I view autonomy controls, then I can decrease autonomy level but cannot increase it beyond Level 2 without Admin approval.

## Notes

Autonomy promotion and demotion workflows are elaborated in US-015. The Level 4 confirmation gate is a deliberate safety affordance aligned with the product's progressive autonomy philosophy.
