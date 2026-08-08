---
id: US-058
title: "Create and Curate a Global MCP Custom-Scope Preset"
slug: "create-a-global-mcp-custom-scope-preset"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "M"
tags: [admin, mcp, scope-preset]
---

# US-058: Create and Curate a Global MCP Custom-Scope Preset

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** create and curate global MCPCustomScope presets,
**So that** org owners across the platform have a vetted, reusable starting point when restricting MCP tool access on their projects.

## Acceptance Criteria

- [ ] Given Ilya is on the admin MCP scope presets page, when he creates a new preset with a name, description, and a specific set of tool groups/tools, then it is saved and becomes selectable by org owners applying scopes to projects.
- [ ] Given Ilya edits an existing global preset's tool selection, when he saves, then projects referencing the preset by name pick up the updated tool set going forward.
- [ ] Given Ilya attempts to delete a global preset currently referenced by one or more projects, when he confirms deletion, then he is shown how many projects reference it before the delete is finalized.
- [ ] Given Ilya duplicates an existing preset as a starting point for a new one, when he saves the duplicate under a new name, then both presets exist independently and editing one does not affect the other.

## Notes

Global presets are platform-wide, distinct from an org owner's project-specific custom tool selection in US-050.
