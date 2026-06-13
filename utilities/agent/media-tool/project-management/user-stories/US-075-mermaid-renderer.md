---
id: US-075
title: "Render Mermaid diagrams to SVG/PNG"
slug: mermaid-renderer
personas: [P-002]
epic: "Renderers"
priority: must-have
complexity: medium
tags: [renderer, mermaid, mmdc, svg]
---

# US-075: Render Mermaid diagrams to SVG/PNG

## User Story

**As a** technical writer
**I want to** Mermaid markup rendered to SVG or PNG
**So that** I can embed diagrams directly in articles and presentations

## Acceptance Criteria

- **Given** a `.mmd` file from generation and `post_processing: { action: render, tool: mermaid }`
  **When** the render step runs
  **Then** an `.svg` file is produced using `mmdc` with the specified theme

- **Given** `output_format: png`
  **When** rendering
  **Then** a `.png` file is produced with configurable width and height

## Notes
Requires `@mermaid-js/mermaid-cli` installed globally. Shells out via subprocess.
