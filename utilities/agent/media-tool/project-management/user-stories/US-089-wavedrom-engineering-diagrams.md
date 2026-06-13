---
id: US-089
title: "Generate WaveDrom timing diagrams"
slug: wavedrom-engineering-diagrams
personas: [P-004]
epic: "Diagram & Text Formats"
priority: could-have
complexity: medium
tags: [diagram, wavedrom, timing, engineering]
---

# US-089: Generate WaveDrom timing diagrams

## User Story

**As a** developer documenting protocol specifications
**I want to** generate WaveDrom timing diagrams from text
**So that** I can visualize signal timing in documentation

## Acceptance Criteria

- **Given** a `.media.prompt` with `text_format: wavedrom`
  **When** generation runs
  **Then** a `.json` file is produced with valid WaveDrom markup

## Notes
WaveDrom uses JSON signal descriptions. Can be rendered via JavaScript in browser or server-side.
