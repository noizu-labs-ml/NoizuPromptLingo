---
id: US-002
title: "Generate wireframe mockup via MCP tool call"
slug: "generate-wireframe-mockup"
personas: [P-001, P-003]
epic: "MCP Core Service"
priority: "must-have"
complexity: "L"
tags: [mcp, wireframe, generation, core]
---

# US-002: Generate wireframe mockup via MCP tool call

## User Story

**As a** full-stack developer (P-001),
**I want to** call a `generate_wireframe` MCP tool with a natural-language description of a screen,
**So that** I receive a usable wireframe mockup without switching to a separate design tool.

## Acceptance Criteria

- [ ] Given a valid prompt string, when `generate_wireframe` is called, then the response includes a rendered wireframe artifact and a metadata object within 30 seconds
- [ ] Given a prompt describing a login screen, when the tool is called, then the wireframe contains recognizable login UI elements (form fields, button, branding placeholder)
- [ ] Given an empty or whitespace-only prompt, when the tool is called, then a structured error is returned indicating a required parameter is missing
- [ ] Given a successful response, when the artifact is returned, then it includes a stable `mockup_id` usable for future iteration calls (US-008)

## Notes

Output format defaults to SVG unless overridden via US-004. The tool must stream a progress event if generation exceeds 5 seconds to prevent AI assistant timeouts. Related to US-004, US-005, US-006, US-008.
