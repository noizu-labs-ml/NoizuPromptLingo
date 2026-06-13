---
id: US-056
title: "Parallel Quest Management"
slug: "parallel-quests"
personas: [P-001, P-004]
epic: "Quest Engine"
priority: "should-have"
complexity: "M"
tags: [quest-engine, parallel, multi-quest, player-state]
---

# US-056: Parallel Quest Management

## User Story

**As an** indie AI game developer (P-001),
**I want to** manage multiple simultaneously active quests per player,
**So that** players can pursue a main story quest alongside side quests without the engine serializing their progress.

## Acceptance Criteria

- [ ] Given a player with no active quests, when `quest_engine.start("main_quest", player_id)` and `quest_engine.start("side_quest_a", player_id)` are both called, then `quest_engine.active_quests(player_id)` returns a list containing both quest instances.
- [ ] Given a player with two active quests, when `instance_a.complete_objective("obj_1")` is called on the first quest, then `instance_b`'s objective states are unchanged.
- [ ] Given a `max_active_quests` limit set to 5 on the `QuestEngine`, when a sixth quest is started for the same player, then a `QuestLimitExceededError` is raised.
- [ ] Given no `max_active_quests` limit configured, when any number of quests are started for a player, then all start successfully without error.
- [ ] Given a player with multiple active quests, when `quest_engine.active_quests(player_id, status="active")` is called, then only quests in `"active"` status are returned.
- [ ] Given two parallel quest instances that both complete in the same turn, when both completion events are processed, then both `RewardEvent`s are emitted and neither overwrites the other's data.

## Notes

Sarah Kim (P-004) runs tabletop sessions where players juggle faction quests and personal story arcs simultaneously. Quest instances are keyed by `(player_id, quest_id)` to avoid collisions. Relates to US-058 for cross-quest dependency tracking.
