---
id: US-092
title: "Generate DrawIO diagrams"
slug: drawio-diagram-generation
personas: [P-002]
epic: "Diagram & Text Formats"
priority: could-have
complexity: medium
tags: [diagram, drawio, xml, complex-layout]
---

# US-092: Generate DrawIO diagrams

## User Story

**As a** technical writer creating complex system diagrams
**I want to** generate DrawIO-compatible files from text descriptions
**So that** I can open and refine them in draw.io

## Acceptance Criteria

- **Given** a `.media.prompt` with `diagram_type: drawio`
  **When** generation runs
  **Then** a `.drawio` file is produced with valid draw.io XML

## Notes
DrawIO output is XML-based and can be opened directly in draw.io for manual refinement.
