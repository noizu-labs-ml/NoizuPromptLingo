---
id: US-027
title: "Zoom and Pan the Knowledge Graph"
slug: "zoom-pan-graph"
personas: [P-001, P-002, P-003, P-008]
epic: "Knowledge Graph"
priority: "must-have"
complexity: "S"
tags: [knowledge-graph, zoom, pan, navigation, d3js]
---

# US-027: Zoom and Pan the Knowledge Graph

## User Story

**As a** game master running a complex homebrew campaign (P-002),
**I want to** zoom in and pan across the knowledge graph canvas,
**So that** I can navigate dense graphs without losing context of where I am in the overall structure.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I scroll the mouse wheel, then the graph zooms in or out centered on the cursor position.
- [ ] Given the knowledge graph is displayed, when I click and drag the canvas background, then the view pans in the direction of the drag.
- [ ] Given the graph is zoomed in, when I double-click the canvas background, then the view resets to fit all nodes within the viewport.
- [ ] Given I am on a touch device, when I use a pinch gesture, then the graph zooms proportionally.
- [ ] Given any zoom/pan state, when I press a "Fit to Screen" button, then all nodes are visible within the viewport with appropriate padding.

## Notes

Depends on US-026. Touch support is required for tablet-using GMs. Zoom bounds should be clamped (e.g., 10%–400%) to prevent users from getting lost.
