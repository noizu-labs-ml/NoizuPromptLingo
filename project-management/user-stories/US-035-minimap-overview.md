---
id: US-035
title: "Minimap and Graph Overview"
slug: "minimap-overview"
personas: [P-001, P-002, P-008]
epic: "Knowledge Graph"
priority: "could-have"
complexity: "M"
tags: [knowledge-graph, minimap, navigation, overview, large-dataset]
---

# US-035: Minimap and Graph Overview

## User Story

**As a** epic novelist navigating a deeply zoomed-in section of a large graph (P-001),
**I want to** see a minimap overlay showing my current viewport position relative to the full graph,
**So that** I can quickly understand where I am and navigate to distant regions without losing my orientation.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I enable the minimap via a toggle button, then a small overview panel (corner-positioned) renders a scaled-down representation of the full graph.
- [ ] Given the minimap is visible, when I zoom or pan the main graph, then the minimap viewport indicator updates in real time to reflect my current position.
- [ ] Given the minimap is visible, when I click or drag within the minimap, then the main graph viewport pans to center on the clicked location.
- [ ] Given I am in a default (full-fit) zoom state, when the minimap is visible, then the viewport indicator covers the entire minimap (indicating everything is visible).
- [ ] Given the universe has fewer than 50 nodes, when the minimap is toggled on, then it is shown but a hint suggests it is most useful for larger graphs.

## Notes

Depends on US-026, US-027, US-034. The minimap is especially valuable in combination with large-dataset performance work (US-034). Should be toggleable/dismissible to preserve screen real estate.
