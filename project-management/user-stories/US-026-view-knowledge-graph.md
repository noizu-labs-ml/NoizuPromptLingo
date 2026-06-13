---
id: US-026
title: "View Knowledge Graph"
slug: "view-knowledge-graph"
personas: [P-001, P-002, P-003, P-008]
epic: "Knowledge Graph"
priority: "must-have"
complexity: "L"
tags: [knowledge-graph, visualization, d3js, universe-explorer]
---

# US-026: View Knowledge Graph

## User Story

**As a** worldbuilder (P-001),
**I want to** view all canon entries in my universe as an interactive node-edge graph,
**So that** I can understand the structural relationships between characters, locations, factions, and events at a glance.

## Acceptance Criteria

- [ ] Given a universe with at least one canon entry, when I navigate to the Knowledge Graph view, then all entries are rendered as nodes and all defined relationships are rendered as edges.
- [ ] Given the graph has loaded, when I view the canvas, then nodes are color-coded by entry type (character, location, event, faction, object, concept, rule).
- [ ] Given the graph has loaded, when I view the canvas, then a legend mapping node colors to entry types is visible.
- [ ] Given a universe with no entries, when I navigate to the Knowledge Graph, then an empty-state prompt guides me to create my first entry.
- [ ] Given the graph is rendering, when it completes, then it does so within 3 seconds for universes with fewer than 200 nodes.

## Notes

Foundational story for the Knowledge Graph epic. All other graph stories (US-027 through US-035) depend on this. Depends on US-005 (Canon Editor — entry creation).
