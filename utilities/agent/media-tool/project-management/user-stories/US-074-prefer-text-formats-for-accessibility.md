---
id: US-074
title: "Generate accessible text formats alongside images"
slug: prefer-text-formats-for-accessibility
personas: [P-007]
epic: "Accessibility"
priority: could-have
complexity: low
tags: [accessibility, text-format, svg, mermaid, a11y]
---

# US-074: Generate accessible text formats alongside images

## User Story

**As an** accessibility engineer
**I want to** generate text source formats (SVG, Mermaid source) alongside rendered images
**So that** the content is accessible to screen readers and text-based tools

## Acceptance Criteria

- **Given** a diagram generation request
  **When** output is produced
  **Then** both the source markup (`.mmd`, `.puml`) and rendered visual (`.svg`, `.png`) are available

- **Given** an SVG is generated
  **When** the file is produced
  **Then** the SVG includes a `<title>` and `<desc>` element for accessibility

## Notes
Text formats are inherently more accessible. SVG should include ARIA-compatible metadata.
