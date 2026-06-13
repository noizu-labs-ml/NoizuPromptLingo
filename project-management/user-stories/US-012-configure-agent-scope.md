---
id: US-012
title: "Configure and Edit Agent Device Scope"
slug: "configure-agent-scope"
personas: [P-001, P-003]
epic: "Agent Management"
priority: "must-have"
complexity: "M"
tags: [agents, configuration, scope, devices, fleet]
---

# US-012: Configure and Edit Agent Device Scope

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** edit an existing agent's device scope after it has been created,
**So that** I can expand or narrow which devices an agent monitors as my fleet and requirements evolve.

## Acceptance Criteria

- [ ] Given I open an agent's configuration page, when I click "Edit Scope," then I can modify the device selection using static device lists, device groups, or dynamic tag-based queries.
- [ ] Given I change a scope query, when I click "Preview," then the updated device count and a diff (devices added vs. removed) are shown before I save.
- [ ] Given I save an updated scope, when the agent reloads, then it begins monitoring the new device set within 30 seconds and logs the scope change as an audit event.
- [ ] Given the scope change removes devices that have active open anomalies, when I save, then I am warned that those anomalies will be archived and given the option to cancel or proceed.

## Notes

Scope changes should not interrupt the agent's operation on devices that remain in scope. Dynamic query scopes re-evaluate as new devices are discovered, automatically including matching new devices.
