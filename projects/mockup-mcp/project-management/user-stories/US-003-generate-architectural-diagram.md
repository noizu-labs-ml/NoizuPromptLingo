---
id: US-003
title: "Generate architectural diagram via MCP"
slug: "generate-architectural-diagram"
personas: [P-001, P-005]
epic: "MCP Core Service"
priority: "must-have"
complexity: "L"
tags: [mcp, architecture, c4, sequence-diagram, plantuml]
---

# US-003: Generate architectural diagram via MCP

## User Story

**As an** enterprise architect (P-005),
**I want to** invoke a `generate_diagram` MCP tool specifying a diagram type (C4 context, C4 container, sequence, component),
**So that** I can generate architecture artifacts programmatically alongside code without manual diagramming.

## Acceptance Criteria

- [ ] Given a `diagram_type` of `c4_context` and a system description, when the tool is called, then a valid C4 context diagram is returned in the requested output format
- [ ] Given a `diagram_type` of `sequence` and interaction steps, when the tool is called, then a syntactically valid PlantUML or Mermaid sequence diagram is returned
- [ ] Given an unsupported `diagram_type` value, when the tool is called, then the error response lists all supported types
- [ ] Given a successful diagram generation, when the artifact is returned, then source markup (PlantUML/Mermaid) is included alongside the rendered image

## Notes

Supported diagram types: `c4_context`, `c4_container`, `c4_component`, `sequence`, `class`, `er`, `flowchart`. Source markup inclusion enables downstream editing. Related to US-004, US-006, US-010.
