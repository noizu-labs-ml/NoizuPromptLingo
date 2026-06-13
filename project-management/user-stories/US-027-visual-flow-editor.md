---
id: US-027
title: "Visual Playbook Flow Editor"
slug: "visual-flow-editor"
personas: [P-007, P-002, P-003]
epic: "Playbook System"
priority: "must-have"
complexity: "XL"
tags: [playbook, visual-editor, flow, drag-and-drop]
---

# US-027: Visual Playbook Flow Editor

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** build playbooks using a drag-and-drop node canvas that visualizes triggers, conditions, and actions as connected flow elements,
**So that** I can design and communicate complex automation logic without writing raw YAML.

## Acceptance Criteria

- [ ] Given I open the visual editor, when I drag trigger, condition, and action nodes onto the canvas and connect them, then the editor generates equivalent valid YAML automatically
- [ ] Given I edit a playbook in YAML view, when I switch to visual view, then the canvas accurately reflects the YAML logic with no information loss
- [ ] Given I connect two incompatible node types (e.g., action directly to action without condition), when I attempt the connection, then the editor displays a validation warning explaining the required structure
- [ ] Given a playbook with branching logic (if/else conditions), when rendered in the visual editor, then branches are clearly distinguished with labeled true/false paths
- [ ] Given I save from the visual editor, then the playbook version history records the change with a diff of the modified YAML

## Notes

This is the primary non-technical authoring surface; operators like P-002 and P-003 rely on this view. Related to US-026 (YAML authoring) — both views must stay in sync. Node library should draw from the action library defined in US-030.
