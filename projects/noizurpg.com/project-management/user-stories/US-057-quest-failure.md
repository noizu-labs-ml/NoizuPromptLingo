---
id: US-057
title: "Quest Failure Conditions"
slug: "quest-failure"
personas: [P-001, P-002]
epic: "Quest Engine"
priority: "should-have"
complexity: "M"
tags: [quest-engine, failure, conditions, narrative-consequence]
---

# US-057: Quest Failure Conditions

## User Story

**As an** indie AI game developer (P-001),
**I want to** declare explicit failure conditions on quests and stages that automatically transition instances to a failed state,
**So that** the game enforces meaningful stakes without me writing custom failure-detection loops.

## Acceptance Criteria

- [ ] Given a quest stage definition with `failure_conditions: [{type: "npc_death", npc_id: "lord_aldric"}]`, when `quest_engine.signal(event_type="npc_death", npc_id="lord_aldric")` is called while that stage is active, then all matching quest instances transition to `status == "failed"` and `failed_at` is recorded.
- [ ] Given a quest stage with a `time_limit_seconds: 300` failure condition, when `instance.elapsed_seconds()` exceeds 300 and `quest_engine.tick()` is called, then the instance transitions to `"failed"`.
- [ ] Given a quest with a failure condition defined at the quest level (not stage level), when the condition event is signalled during any stage, then the entire quest fails regardless of current stage.
- [ ] Given a failed `QuestInstance`, when `quest_engine.restart(instance_id)` is called and the quest definition has `allow_restart: true`, then a new instance is created with `status == "active"` and the original instance is archived.
- [ ] Given a quest definition with `on_failure` callback set, when an instance transitions to `"failed"`, then the callback is invoked with the `QuestInstance` as its argument.
- [ ] Given a `QuestInstance` in `"failed"` status, when `instance.failure_reason` is accessed, then it returns the name of the failure condition that triggered the transition.

## Notes

Elena Vasquez (P-002) requires failure narratives; the `on_failure` callback receives the full instance so narrative text can be generated. Relates to US-053 for the state machine that governs valid transitions into `"failed"`.
