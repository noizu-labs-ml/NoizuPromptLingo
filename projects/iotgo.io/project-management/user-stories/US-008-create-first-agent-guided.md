---
id: US-008
title: "Create First Agent via Guided Flow"
slug: "create-first-agent-guided"
personas: [P-001, P-003]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "M"
tags: [onboarding, agents, wizard, first-run]
---

# US-008: Create First Agent via Guided Flow

## User Story

**As a** Smart Building Facility Manager (P-003),
**I want to** create my first AI agent using a guided template-based flow,
**So that** I can start monitoring my building systems without needing to understand all agent configuration details upfront.

## Acceptance Criteria

- [ ] Given I reach the "Create First Agent" wizard step, when the page loads, then I am presented with a gallery of agent templates (e.g., "Anomaly Monitor," "Energy Optimizer," "Connectivity Watchdog") with plain-language descriptions.
- [ ] Given I select a template, when I proceed, then I am prompted to select the device scope (all devices, a device group, or specific devices) from my already-discovered inventory.
- [ ] Given I configure device scope and confirm, when I click "Create Agent," then the agent is created in autonomy Level 1 (Notify Only) by default with a clearly visible label indicating it will not take automated action.
- [ ] Given the agent is created, when I view the agent card, then I see its name, template type, device count, autonomy level, and a status of "Initializing" that transitions to "Active" within 60 seconds.

## Notes

Advanced agent creation without a template is covered in US-011. Default autonomy Level 1 is intentional safety behavior — promotion requires explicit action per US-015.
