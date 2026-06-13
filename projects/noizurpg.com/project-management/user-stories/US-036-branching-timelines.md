---
id: US-036
title: "Branching timeline support"
slug: "branching-timelines"
personas: [P-003]
epic: "World State Manager"
priority: "could-have"
complexity: "L"
tags: [world-state, timeline, branching, multiverse, research]
---

# US-036: Branching Timeline Support

## User Story

**As a** AI/ML researcher exploring counterfactual narrative scenarios (P-003),
**I want to** fork world state at any timeline point, advance divergent branches independently, and compare their outcomes,
**So that** I can study how different decision paths lead to different emergent world states without manually resetting and replaying.

## Acceptance Criteria

- [ ] Given a world at tick T, when I call `branch = world.fork(label="alt_path")`, then a new independent `World` instance is returned sharing the state at tick T but isolated from further mutations on the original.
- [ ] Given two branched worlds derived from the same fork point, when I mutate world state on one branch, then the other branch's state is unaffected.
- [ ] Given a forked world, when I call `world.branch_info()`, then the response includes `fork_tick`, `parent_id`, and `label`.
- [ ] Given a parent world with three forks, when I call `world.list_forks()`, then all three fork metadata records are returned.
- [ ] Given two branches from a common ancestor, when I call `world.diff(branch_A, branch_B)`, then a structured diff is returned listing changed locations, faction relations, timeline events, and economy states between the two branches.
- [ ] Given a fork with no mutations applied, when compared to its parent snapshot, then `world.diff()` returns an empty diff.

## Notes

This feature is primarily for P-003's research workflows and advanced developers stress-testing narrative divergence. Depends on US-031 (world snapshots) for forking mechanics and US-029 (timeline) for branching context. The diff utility is key for quantitative analysis of narrative outcomes.
