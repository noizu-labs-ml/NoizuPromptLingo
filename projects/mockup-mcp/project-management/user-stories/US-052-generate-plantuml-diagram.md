---
id: US-052
title: "Generate PlantUML diagram from text description"
slug: "generate-plantuml-diagram"
personas: [P-001, P-005]
epic: "Diagram & Rendering Engine"
priority: "must-have"
complexity: "M"
tags: [plantuml, diagram, rendering, architecture]
---

# US-052: Generate PlantUML Diagram from Text Description

## User Story

**As a** Enterprise Architect (P-005),
**I want to** describe a system or process in plain text and receive a rendered PlantUML diagram,
**So that** I can document architecture without manually authoring PlantUML syntax.

## Acceptance Criteria

- [ ] Given a natural language description, when the MCP tool is invoked, then valid PlantUML source code is generated and rendered to PNG or SVG
- [ ] Given the description specifies a diagram type (sequence, class, component, state), when processed, then the correct PlantUML diagram type is produced
- [ ] Given successful generation, when the result is returned, then both the rendered image and the raw PlantUML source are included in the response payload
- [ ] Given PlantUML rendering fails due to syntax error, when this occurs, then the raw source is returned with an error annotation so the caller can debug or retry

## Notes

Raw PlantUML source must be included in the response to support US-057 (API spec sequence diagrams) and US-058 (ER diagrams). Rendering is handled server-side via a PlantUML JAR or hosted render service.
