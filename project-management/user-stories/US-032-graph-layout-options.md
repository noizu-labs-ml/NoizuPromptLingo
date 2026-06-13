---
id: US-032
title: "Graph Layout Options"
slug: "graph-layout-options"
personas: [P-001, P-002, P-003, P-008]
epic: "Knowledge Graph"
priority: "should-have"
complexity: "M"
tags: [knowledge-graph, layout, force-directed, hierarchical, d3js]
---

# US-032: Graph Layout Options

## User Story

**As a** epic novelist who thinks in narrative arcs rather than networks (P-001),
**I want to** switch between different graph layout algorithms,
**So that** I can find the arrangement that best reveals the structure I care about — whether that's influence hierarchies, geographic clustering, or organic relationship webs.

## Acceptance Criteria

- [ ] Given the knowledge graph is displayed, when I open layout options, then I can choose from at least three layouts: Force-Directed (default), Hierarchical (top-down), and Radial (central node + rings).
- [ ] Given I select a new layout, when the graph transitions, then nodes animate smoothly to their new positions over 500–800ms.
- [ ] Given I switch to Hierarchical layout, when prompted, then I can select which node type or specific node serves as the hierarchy root.
- [ ] Given I apply a layout, when I later return to the graph, then the last-used layout is restored as the default for that universe.
- [ ] Given a layout is computing for a large graph, when it takes more than 1 second, then a loading indicator is shown.

## Notes

Depends on US-026. Force-directed is the must-have default; hierarchical and radial are the should-have additions. Additional layouts (e.g., timeline, geographic map overlay) are won't-have-yet.
