---
id: US-031
title: "World state snapshots for save/load"
slug: "world-snapshots"
personas: [P-001, P-004]
epic: "World State Manager"
priority: "must-have"
complexity: "M"
tags: [world-state, persistence, save-load, serialization]
---

# US-031: World State Snapshots for Save/Load

## User Story

**As a** tabletop GM running multi-session campaigns (P-004),
**I want to** save the complete world state to disk at any point and restore it exactly in a later session,
**So that** the game can be paused and resumed without losing location states, faction standings, timeline events, or economic data.

## Acceptance Criteria

- [ ] Given a fully configured world (locations, factions, timeline, rules), when I call `world.snapshot()`, then a JSON-serializable dict is returned capturing the complete state.
- [ ] Given a snapshot dict, when I call `World.from_snapshot(snapshot)`, then the restored world is structurally identical to the original, verified by comparing `world.snapshot()` on both instances.
- [ ] Given a snapshot saved to a file via `world.save("savefile.json")`, when I call `World.load("savefile.json")`, then the world is restored without error and all entities are present.
- [ ] Given a snapshot from a previous version of the framework (minor version bump), when I call `World.load()` on it, then a migration is attempted and a deprecation warning is raised if fields differ, rather than a hard crash.
- [ ] Given a world with 500 locations and 1000 timeline events, when I call `world.snapshot()`, then the operation completes in under 500ms on commodity hardware.

## Notes

Save/load is a table-stakes feature for P-004 who runs weekly campaigns. Snapshots are also used by the testing harness (US-036 branching timelines) to fork world state for alternate scenario exploration. All other World State Manager stories should ensure their data is captured in snapshots.
