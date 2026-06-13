---
id: US-054
title: "Generate SVG mockup with interactive hotspots"
slug: "generate-svg-with-hotspots"
personas: [P-003, P-004]
epic: "Diagram & Rendering Engine"
priority: "should-have"
complexity: "L"
tags: [svg, hotspots, interactive, wireframe, prototype]
---

# US-054: Generate SVG Mockup with Interactive Hotspots

## User Story

**As a** UX Designer (P-003),
**I want to** generate an SVG wireframe where UI regions are annotated as clickable hotspots with metadata,
**So that** stakeholders can interact with the mockup and leave contextual feedback on specific components.

## Acceptance Criteria

- [ ] Given a wireframe generation request with hotspot flag enabled, when the SVG is returned, then interactive `<a>` or `data-hotspot` annotated regions are embedded for each identified UI component
- [ ] Given the generated SVG is loaded in the companion website, when a hotspot is clicked, then a feedback panel opens anchored to that component
- [ ] Given a hotspot definition, when inspected, then it contains a component ID, label, and bounding box coordinates
- [ ] Given an SVG without hotspot support (e.g., raw diagram), when requested without the flag, then a plain SVG without hotspot annotations is returned

## Notes

Hotspot metadata is the bridge between the MCP rendering engine and the companion feedback site. Related to US-026 (share mockup via link) — shared links should preserve hotspot interactivity.
