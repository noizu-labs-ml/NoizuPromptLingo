---
id: US-048
title: "Customize template options before generation"
slug: "customize-template-options"
personas: [P-001, P-004]
epic: "MCP Jumpstart"
priority: "must-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, customization, configuration]
---

# US-048: Customize Template Options Before Generation

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** customize template options (project name, tool names, transport, auth, extra features) before the project is generated,
**So that** the scaffolded project reflects my specific requirements without requiring post-generation manual edits.

## Acceptance Criteria

- [ ] Given the user has selected a language (US-039) and template (US-040), when the customization step loads, then it presents a form with configurable options: project name, description, tool names (add/remove/rename), transport selection, auth method, and optional features.
- [ ] Given the user edits the project name, when they enter a value, then the system validates it as a valid package/repository name (no spaces, lowercase, hyphens allowed) and shows validation feedback inline.
- [ ] Given the user adds custom tools, when they define a tool name and parameters, then the system generates a tool schema entry and a corresponding handler stub will be included in the output.
- [ ] Given the user toggles optional features (Docker/K8s manifests US-044, CI/CD US-045, test harness US-046, auth middleware US-043), when they enable or disable a feature, then the file tree preview (US-047) updates to reflect the inclusion or exclusion.
- [ ] Given the user selects transport types, when they choose from stdio, SSE, and WebSocket options, then at least one transport must be selected and the system warns if none are chosen.
- [ ] Given the user modifies options, when they click "Reset to defaults," then all customization fields revert to the template's default values.

## Notes

Customization is the key step between template selection and generation. Options should have sensible defaults so users can skip customization and generate immediately. Related: US-040 (template), US-041 (generation), US-047 (preview).
