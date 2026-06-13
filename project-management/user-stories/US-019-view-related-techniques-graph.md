---
id: US-019
title: "View Related Techniques Graph"
slug: "view-related-techniques-graph"
personas: [P-001, P-004, P-006]
epic: "Attack Catalog"
priority: "could-have"
complexity: "L"
tags: [catalog, technique, graph, relationships, research]
---

# US-019: View Related Techniques Graph

## User Story

**As a** red team researcher mapping the attack surface (P-001, P-004, P-006),
**I want to** visualize the relationships between a technique and related techniques as an interactive graph,
**So that** I can understand the technique's lineage, variants, and chaining potential during threat modeling.

## Acceptance Criteria

- [ ] Given I am on a technique detail page, when I open the Related Techniques section, then I see an interactive graph showing the current technique as the focal node with edges to related techniques labeled by relationship type (variant-of, extends, chained-with, precedes)
- [ ] Given I click a node in the graph, when navigating, then I am taken to that technique's detail page
- [ ] Given the graph has more than 20 nodes, when rendering, then the graph is paginated or clustered to avoid visual overflow, with an option to expand to the full graph
- [ ] Given I prefer a list view, when I toggle from graph to list, then related techniques are shown as a table with relationship type, technique name, and severity badge

## Notes

Graph rendering should use a library like Cytoscape.js or D3 force-directed layout. Relationship data is maintained by the catalog team. This is a rich feature that differentiates from a static list — acceptable to defer to a later sprint.
