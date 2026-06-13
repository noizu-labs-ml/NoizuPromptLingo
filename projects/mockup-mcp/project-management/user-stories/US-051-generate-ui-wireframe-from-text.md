---
id: US-051
title: "Generate UI wireframe from natural language description"
slug: "generate-ui-wireframe-from-text"
personas: [P-001, P-003, P-004]
epic: "Diagram & Rendering Engine"
priority: "must-have"
complexity: "L"
tags: [wireframe, ai-generation, nlp, rendering]
---

# US-051: Generate UI Wireframe from Natural Language Description

## User Story

**As a** UX Designer (P-003),
**I want to** describe a screen in plain English and receive a rendered wireframe,
**So that** I can rapidly prototype interface concepts without manual drawing tools.

## Acceptance Criteria

- [ ] Given a natural language prompt, when submitted via MCP tool call, then a wireframe image (PNG or SVG) is returned within 30 seconds
- [ ] Given the prompt includes layout keywords (e.g., "sidebar", "modal", "card grid"), when rendered, then the wireframe reflects those structural patterns
- [ ] Given an invalid or empty prompt, when submitted, then a structured error response is returned with a human-readable message
- [ ] Given a successful generation, when the result is returned, then a unique artifact ID is included for subsequent retrieval or modification

## Notes

Primary entry point for AI-assisted wireframing. Feeds into US-054 (interactive hotspots) and US-062 (responsive variants). Generation quality depends on the underlying image AI model configured in the Phoenix backend.
