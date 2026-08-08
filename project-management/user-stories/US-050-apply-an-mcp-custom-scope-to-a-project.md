---
id: US-050
title: "Apply an MCP Custom Scope to a Project"
slug: "apply-an-mcp-custom-scope-to-a-project"
personas: [P-004]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "M"
tags: [mcp, custom-scope, project-config]
---

# US-050: Apply an MCP Custom Scope to a Project

## User Story

**As a** Org Owner, Marcus Chen (P-004),
**I want to** apply an MCPCustomScope — a named preset or a custom tool-group/tool selection — to a project,
**So that** I can restrict which MCP tools coding-agent harnesses are allowed to invoke against that project's sensitive data.

## Acceptance Criteria

- [ ] Given Marcus is on a project's MCP settings page, when he selects a predefined scope preset and saves, then the project's exposed tool list updates to exactly the tools in that preset.
- [ ] Given Marcus instead builds a custom scope by selecting individual tool groups and tools, when he saves, then the project persists that exact custom selection rather than a preset reference.
- [ ] Given a scope has just been applied to a project, when an agent lists available MCP tools for that project, then only the tools permitted by the active scope are returned.
- [ ] Given Marcus removes a tool from an active custom scope, when he saves the change, then an in-flight agent session against that project can no longer successfully call the removed tool on its next request.

## Notes

Primary lever gating what an autonomous agent (P-002) can do inside a project. Global preset curation is handled separately by platform admins in US-058.
