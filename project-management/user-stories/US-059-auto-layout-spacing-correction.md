---
id: US-059
title: "Auto-layout and spacing correction on generated diagrams"
slug: "auto-layout-spacing-correction"
personas: [P-003, P-001]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "M"
tags: [layout, spacing, post-processing, diagram, quality]
---

# US-059: Auto-Layout and Spacing Correction on Generated Diagrams

## User Story

**As a** UX Designer (P-003),
**I want to** have generated diagrams automatically corrected for overlapping elements and uneven spacing,
**So that** the output is presentation-ready without manual cleanup in an external tool.

## Acceptance Criteria

- [ ] Given a generated diagram with overlapping nodes, when post-processing runs, then elements are repositioned to eliminate overlaps while preserving logical groupings
- [ ] Given a diagram with inconsistent spacing between similar elements, when auto-layout is applied, then spacing is normalized to a consistent grid or gap value
- [ ] Given a user request with `layout: false` in the options, when processed, then auto-layout is skipped and raw generation output is returned as-is
- [ ] Given auto-layout is applied, when the result is returned, then a flag in the response indicates that layout correction was performed

## Notes

Auto-layout runs as a post-processing step after raw AI generation. For PlantUML and Mermaid, this may mean regenerating with layout hints rather than pixel-level correction. The `layout: false` escape hatch is important for power users who want raw output.
