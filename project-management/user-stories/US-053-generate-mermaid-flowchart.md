---
id: US-053
title: "Generate Mermaid flowchart from text description"
slug: "generate-mermaid-flowchart"
personas: [P-001, P-002, P-005]
epic: "Diagram & Rendering Engine"
priority: "must-have"
complexity: "M"
tags: [mermaid, flowchart, diagram, rendering]
---

# US-053: Generate Mermaid Flowchart from Text Description

## User Story

**As a** Product Manager (P-002),
**I want to** describe a process or workflow in plain language and receive a Mermaid diagram,
**So that** I can include clear flow diagrams in specs and documentation without learning Mermaid syntax.

## Acceptance Criteria

- [ ] Given a natural language process description, when the MCP tool is called, then valid Mermaid source and a rendered PNG/SVG are returned
- [ ] Given the description implies a specific diagram type (flowchart, sequence, Gantt, pie), when processed, then the appropriate Mermaid diagram type is selected
- [ ] Given the returned Mermaid source, when pasted into a Mermaid-compatible renderer (e.g., GitHub markdown), then it renders correctly without modification
- [ ] Given a render failure, when this occurs, then the raw Mermaid source is still returned so the caller can self-render client-side

## Notes

Mermaid's broad support in GitHub, Notion, and documentation tools makes this a high-value output format for P-002. Raw source return is critical for embedding in markdown-first workflows.
