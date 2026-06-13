---
id: US-058
title: "Generate Graphviz diagrams"
slug: graphviz-diagram-generation
personas: [P-002, P-003]
epic: "Diagram & Text Formats"
priority: should-have
complexity: medium
tags: [diagram, graphviz, dot, dependency-graph]
---

# US-058: Generate Graphviz diagrams

## User Story

**As a** developer documenting system architecture
**I want to** generate Graphviz DOT diagrams from text descriptions
**So that** I can create dependency graphs and network topologies

## Acceptance Criteria

- **Given** a `.media.prompt` with `diagram_type: graphviz`
  **When** generation runs
  **Then** both `.dot` source and rendered `.svg` are produced

- **Given** `dot` is not installed
  **When** the render step executes
  **Then** a clear message tells me to `brew install graphviz`

## Notes
Graphviz `dot` command produces SVG, PNG, or PDF. Layout can be `dot`, `neato`, `fdp`, etc.
