---
id: US-004
title: "Specify output format for mockup generation"
slug: "specify-output-format"
personas: [P-001, P-003, P-005]
epic: "MCP Core Service"
priority: "must-have"
complexity: "S"
tags: [mcp, output-format, svg, png, mermaid, plantuml]
---

# US-004: Specify output format for mockup generation

## User Story

**As a** full-stack developer (P-001),
**I want to** pass an `output_format` parameter to any mockup or diagram tool,
**So that** the artifact is returned in the format that best fits my downstream use case (inline in docs, rendered in browser, or editable markup).

## Acceptance Criteria

- [ ] Given `output_format: "svg"`, when any generation tool is called, then the response includes a valid inline SVG string
- [ ] Given `output_format: "png"`, when any generation tool is called, then the response includes a base64-encoded PNG and a content-type field
- [ ] Given `output_format: "mermaid"`, when a compatible tool is called, then the response includes raw Mermaid source with no rendered artifact
- [ ] Given `output_format: "plantuml"`, when a compatible tool is called, then the response includes raw PlantUML source
- [ ] Given an invalid `output_format` value, when the tool is called, then the error response lists accepted values and the tool's default

## Notes

Not all formats are available for all tools — wireframes cannot be returned as Mermaid source. The error message must be specific about which tool-format combinations are valid. Default format is `svg` across all tools unless configured per API key.
