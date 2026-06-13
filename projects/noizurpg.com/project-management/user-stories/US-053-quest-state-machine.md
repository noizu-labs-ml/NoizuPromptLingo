---
id: US-053
title: "Track Quest Progress Through State Machine"
slug: "quest-state-machine"
personas: [P-001]
epic: "Quest Engine"
priority: "must-have"
complexity: "M"
tags: [quest-engine, state-machine, progress-tracking, transitions]
---

# US-053: Track Quest Progress Through State Machine

## User Story

**As an** indie AI game developer (P-001),
**I want to** advance quest instances through a well-defined state machine,
**So that** quest lifecycle (not started → active → completed/failed) is managed consistently without custom tracking logic in my game code.

## Acceptance Criteria

- [ ] Given a registered quest, when `quest_engine.start(quest_id, player_id)` is called, then a `QuestInstance` is returned with `status == "active"` and `started_at` timestamp set.
- [ ] Given an active `QuestInstance`, when `instance.complete_objective(objective_id)` is called with a valid objective ID, then `instance.objectives[objective_id].completed == True` and the completion timestamp is recorded.
- [ ] Given an active `QuestInstance` where all required objectives are complete, when `instance.advance_stage()` is called and no further stages remain, then `instance.status` transitions to `"completed"` and `completed_at` is set.
- [ ] Given an active `QuestInstance` with a next stage defined, when `instance.advance_stage()` is called, then `instance.current_stage` updates to the next stage and objectives reset to incomplete for the new stage.
- [ ] Given a `QuestInstance` in `"completed"` or `"failed"` status, when `instance.complete_objective()` or `instance.advance_stage()` is called, then an `InvalidTransitionError` is raised.
- [ ] Given a `QuestInstance`, when `instance.to_dict()` is called, then the returned dict is JSON-serializable and round-trips through `QuestInstance.from_dict()` without data loss.

## Notes

Builds on US-051. The state machine statuses are: `not_started`, `active`, `completed`, `failed`, `abandoned`. US-057 covers the `failed` transition. Instance serialization supports US-074 (session persistence).
