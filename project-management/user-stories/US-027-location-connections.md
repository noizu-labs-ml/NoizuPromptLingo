---
id: US-027
title: "Connect locations with paths"
slug: "location-connections"
personas: [P-001]
epic: "World State Manager"
priority: "must-have"
complexity: "S"
tags: [world-state, locations, graph, traversal]
---

# US-027: Connect Locations with Paths

## User Story

**As a** indie AI game developer (P-001),
**I want to** define directed or bidirectional paths between locations with optional metadata (travel time, required conditions),
**So that** movement, navigation queries, and world traversal can be computed programmatically and injected into LLM context.

## Acceptance Criteria

- [ ] Given two registered locations A and B, when I call `world.connect(A, B, bidirectional=True)`, then `world.neighbors(A)` returns B and `world.neighbors(B)` returns A.
- [ ] Given a directed connection from A to B, when I call `world.neighbors(A)`, then B is included; when I call `world.neighbors(B)`, then A is NOT included.
- [ ] Given a path with metadata `{"travel_time": 2, "requires": "horse"}`, when I call `world.get_path(A, B)`, then the metadata dict is returned alongside the connection.
- [ ] Given a connection attempt referencing an unregistered location ID, when I call `world.connect(A, "unknown_id")`, then an `UnknownLocationError` is raised.
- [ ] Given a world with connected locations, when I call `world.shortest_path(start, end)`, then a list of location IDs representing the shortest route is returned, or `None` if no path exists.

## Notes

Depends on US-026. Path metadata will be used by the Narrative Engine when generating travel descriptions and by the Quest Engine for waypoint validation.
