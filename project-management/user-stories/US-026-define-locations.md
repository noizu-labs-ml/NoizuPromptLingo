---
id: US-026
title: "Define locations with properties"
slug: "define-locations"
personas: [P-001, P-002]
epic: "World State Manager"
priority: "must-have"
complexity: "S"
tags: [world-state, locations, schema]
---

# US-026: Define Locations with Properties

## User Story

**As a** indie AI game developer (P-001),
**I want to** define named locations with typed properties such as region, biome, danger level, and custom attributes,
**So that** the World State Manager can ground NPC behavior and narrative generation in spatially-anchored context.

## Acceptance Criteria

- [ ] Given a Python dict or YAML config, when I call `world.add_location(id, **props)`, then the location is stored and retrievable by its ID without error.
- [ ] Given a location definition with required fields `id` and `name`, when I omit either field, then a `LocationValidationError` is raised with a descriptive message.
- [ ] Given a location with custom properties (e.g. `danger_level=7`, `biome="tundra"`), when I call `world.get_location(id)`, then all properties are returned with their original types preserved.
- [ ] Given two location definitions sharing the same ID, when the second is added, then a `DuplicateLocationError` is raised unless `overwrite=True` is passed.
- [ ] Given a registered location, when I call `world.list_locations()`, then it appears in the returned list with at minimum its `id` and `name`.

## Notes

This is the foundational story for the World State Manager epic; US-027 (location connections) and US-034 (NPC population) depend on locations existing. Designers like P-002 will rely on rich property sets to drive atmosphere in narrative prompts.
