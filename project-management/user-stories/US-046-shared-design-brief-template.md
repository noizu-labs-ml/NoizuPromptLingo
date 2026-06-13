---
id: US-046
title: "Create a Shared Design Brief/Template"
slug: "shared-design-brief-template"
personas: [P-003, P-002, P-005]
epic: "Team & Collaboration"
priority: "should-have"
complexity: "M"
tags: [templates, design-brief, reusability, workspace]
---

# US-046: Create a Shared Design Brief/Template

## User Story

**As a** UX designer (P-003),
**I want to** create a reusable design brief template in the workspace,
**So that** new mockup requests follow a consistent structure and reduce setup time for recurring project types.

## Acceptance Criteria

- [ ] Given a workspace, when I navigate to Templates and click "New Template", then I can define a named template with structured fields (goal, audience, constraints, output format)
- [ ] Given a saved template, when a team member creates a new mockup, then they can select the template and pre-fill the brief fields
- [ ] Given a template, when I edit it, then existing mockups using the template are not retroactively altered
- [ ] Given shared templates, when I view the template library, then all workspace templates are listed with author and last-modified date

## Notes

Templates should be scoped to the workspace and visible to all members regardless of role. Template fields should map to MCP tool parameters where applicable, enabling direct generation from brief data.
