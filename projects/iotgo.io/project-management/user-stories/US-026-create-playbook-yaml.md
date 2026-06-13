---
id: US-026
title: "Create Playbook in YAML"
slug: "create-playbook-yaml"
personas: [P-007, P-001]
epic: "Playbook System"
priority: "must-have"
complexity: "M"
tags: [playbook, yaml, authoring, automation]
---

# US-026: Create Playbook in YAML

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** write and save automation playbooks using a structured YAML schema,
**So that** I can define precise trigger conditions and action sequences using a format that integrates with version control and CI/CD pipelines.

## Acceptance Criteria

- [ ] Given I am in the Playbook Editor, when I select "New Playbook (YAML)", then a schema-aware editor opens with syntax highlighting and inline validation
- [ ] Given I write a valid playbook YAML, when I click Save, then the playbook is stored and appears in the playbook library with name, version, and author metadata
- [ ] Given I write invalid YAML or violate the playbook schema, when I attempt to save, then inline errors identify the offending line and describe the required fix
- [ ] Given a saved playbook, when I view it, then I can toggle between YAML source and a read-only visual summary of its logic

## Notes

The YAML schema should support triggers, conditions, actions, and metadata blocks. Related to US-027 (visual flow editor) — both views should edit the same underlying playbook model. See also US-028 for condition building.
