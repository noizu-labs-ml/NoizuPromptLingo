---
id: US-004
title: "Generate a diagram with Mermaid rendering"
slug: generate-diagram-with-render
personas: [P-002]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [diagram, mermaid, render-chain]
---

# US-004: Generate a diagram with Mermaid rendering

## User Story

**As a** technical writer
**I want to** generate a Mermaid diagram from text and render it to SVG
**So that** I can embed publication-quality diagrams in my articles

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: diagram`, `diagram_type: mermaid`, and a post_processing render step
  **When** I run generation
  **Then** both `.mmd` (raw Mermaid) and `.svg` (rendered) files are produced

- **Given** `mmdc` is not installed
  **When** the render step executes
  **Then** a clear error message tells me how to install mermaid-cli

## Notes
Two-step pipeline: chat completion generates markup, then renderer converts to visual.
