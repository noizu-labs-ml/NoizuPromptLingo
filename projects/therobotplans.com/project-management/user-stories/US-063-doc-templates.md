---
id: US-063
title: "Create and manage document templates for common doc types"
personas: [james-oduya]
domain: docs
priority: low
mvp_phase: "v0.3"
---

## User Story

As a **James Oduya (Agency Owner)**, I want to create and manage document templates for ADRs, runbooks, RFCs, and postmortems so that my team produces consistent documentation across all client projects.

## Acceptance Criteria

- [ ] Template library supports creating, editing, cloning, and archiving templates
- [ ] Templates include placeholder variables (project name, date, author) that auto-populate on use
- [ ] Templates can be scoped to workspace-level or organization-level visibility
- [ ] Creating a new document from a template pre-fills structure and prompts the user for required sections
- [ ] Each template tracks usage count and last-used date for library maintenance

## Notes

Agency context means templates need to be reusable across client projects while allowing per-client customization. The scale-free model means a "template" is itself an item that can be linked, tagged, and versioned. Consider agent-assisted template creation where the agent suggests structure based on doc type best practices.
