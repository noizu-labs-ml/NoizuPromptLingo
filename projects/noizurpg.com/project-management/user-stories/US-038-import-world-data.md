---
id: US-038
title: "Import world from YAML/JSON"
slug: "import-world-data"
personas: [P-002, P-004]
epic: "World State Manager"
priority: "must-have"
complexity: "S"
tags: [world-state, import, yaml, json, configuration]
---

# US-038: Import World from YAML/JSON

## User Story

**As a** tabletop GM with an existing campaign compendium (P-004),
**I want to** define my entire world — locations, connections, factions, rules, and initial timeline events — in YAML or JSON files and import them in a single call,
**So that** I can maintain world data in human-readable config files version-controlled alongside my project rather than writing Python initialization code.

## Acceptance Criteria

- [ ] Given a valid YAML file with `locations`, `connections`, `factions`, and `rules` top-level keys, when I call `World.from_yaml("world.yaml")`, then a fully configured `World` instance is returned with all entities registered.
- [ ] Given a valid JSON file with the same structure, when I call `World.from_json("world.json")`, then the result is equivalent to importing the same data via YAML.
- [ ] Given a YAML file with a missing required field on a location entry (e.g. no `name`), when import is attempted, then a `WorldImportError` is raised identifying the file path, entity type, and offending field.
- [ ] Given a YAML file defining location connections referencing an ID not defined in the same file, when import is attempted, then a `WorldImportError` is raised listing the undefined reference.
- [ ] Given a successfully imported world, when I call `world.snapshot()` and compare it to a world built programmatically with identical data, then the two snapshots are structurally equal.
- [ ] Given a world YAML with 200 locations and 500 connections, when import completes, then the operation finishes in under 2 seconds on commodity hardware.

## Notes

P-002 prefers data-driven workflows to minimize Python boilerplate; P-004 wants to maintain campaign data in files alongside session notes. This story is small because the object model is defined by prior stories — import is purely a deserialization concern. Relates to US-031 (snapshots) for round-trip validation.
