---
id: US-032
title: "Playbook Templates"
slug: "playbook-templates"
personas: [P-007, P-003, P-002, P-008]
epic: "Playbook System"
priority: "should-have"
complexity: "M"
tags: [playbook, templates, onboarding, reuse]
---

# US-032: Playbook Templates

## User Story

**As a** Junior IoT Technician/Field Operator (P-008),
**I want to** start a new playbook from a pre-built template matched to common IoT scenarios,
**So that** I can deploy functional automation quickly without needing deep expertise in playbook authoring.

## Acceptance Criteria

- [ ] Given I create a new playbook, when I browse the template gallery, then templates are organized by category (HVAC, industrial equipment, predictive maintenance, connectivity) with a description and scenario summary
- [ ] Given I select a template, when I instantiate it, then a copy is created in my workspace with all required fields marked for customization and optional fields pre-filled with sensible defaults
- [ ] Given a template requires a specific device type or telemetry schema, when it is applied to a fleet segment that does not match, then the editor flags which fields need to be remapped
- [ ] Given IoTGo ships system-provided templates, when a new version of a template is released, then I am notified and can choose to apply updates to existing playbooks derived from it

## Notes

Templates lower the barrier for P-008 and P-002 who are not automation engineers. Templates can also be contributed via the marketplace (US-033). System templates should cover at least 5 built-in scenarios at launch.
