---
id: US-011
title: "Create Agent with Advanced Configuration"
slug: "create-agent-advanced"
personas: [P-001, P-007]
epic: "Agent Management"
priority: "must-have"
complexity: "L"
tags: [agents, configuration, playbooks, autonomy, advanced]
---

# US-011: Create Agent with Advanced Configuration

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** create an AI agent with full control over its scope, detection logic, playbook assignments, and autonomy level,
**So that** I can precisely tailor agent behavior to a specific device group's operational requirements.

## Acceptance Criteria

- [ ] Given I navigate to Agents → New Agent, when I skip template selection, then I am presented with a form covering: name, description, device scope (group or query), detection rules, assigned playbooks, and autonomy level selector.
- [ ] Given I configure the device scope using a query (e.g., tag:building=A AND type:hvac), when I preview the scope, then the UI shows a count of matched devices and a sample list of up to 20 device names.
- [ ] Given I set an autonomy level, when I hover the level selector, then a tooltip explains what actions the agent can take autonomously at that level versus what requires human approval.
- [ ] Given I assign a playbook, when the agent detects a condition matching the playbook's trigger, then the agent executes or queues (per autonomy level) the playbook's remediation steps.
- [ ] Given I submit the form with all required fields, when the agent is created, then it appears in the agent list with status "Initializing" and transitions to "Active" within 60 seconds of first telemetry processing.

## Notes

Playbook authoring is owned by P-007 and covered in a separate Playbooks epic. Detection rules use a structured condition builder; raw DSL editing is a could-have for a later story.
