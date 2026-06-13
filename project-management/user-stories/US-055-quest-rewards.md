---
id: US-055
title: "Quest Reward System"
slug: "quest-rewards"
personas: [P-001, P-004]
epic: "Quest Engine"
priority: "should-have"
complexity: "M"
tags: [quest-engine, rewards, items, experience, callbacks]
---

# US-055: Quest Reward System

## User Story

**As an** indie AI game developer (P-001),
**I want to** declare rewards on quest stages and completion milestones that are automatically dispatched when earned,
**So that** my game loop receives structured reward events without polling quest state.

## Acceptance Criteria

- [ ] Given a quest stage definition containing a `rewards` list with `{type: "xp", amount: 250}`, when `instance.advance_stage()` completes that stage, then a `RewardEvent(type="xp", amount=250, source_quest_id=..., source_stage_id=...)` is emitted to the registered reward handler.
- [ ] Given a quest completion definition with `rewards: [{type: "item", item_id: "magic_sword"}]`, when `instance.status` transitions to `"completed"`, then a `RewardEvent` with `type="item"` and `item_id="magic_sword"` is emitted.
- [ ] Given no reward handler registered on the `QuestEngine`, when a quest stage completes with rewards defined, then rewards are queued internally and retrievable via `quest_engine.pending_rewards(player_id)`.
- [ ] Given a registered reward handler that raises an exception, when a reward event is dispatched, then the exception is caught, logged at WARNING level, and the quest state transition still succeeds.
- [ ] Given a quest with `conditional_rewards` where a reward has `condition: "branch == 'hero_path'"`, when the quest completes on the `hero_path` branch, then the conditional reward is emitted; when completed on a different branch, it is not.

## Notes

Sarah Kim (P-004) needs tabletop-style rewards (gold, items, XP) to mirror TTRPG systems. Reward handler is a callable registered via `quest_engine.on_reward(handler)`. See US-054 for branch context used in conditional rewards.
