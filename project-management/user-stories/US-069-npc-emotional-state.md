---
id: US-069
title: "Emotional State Tracking for NPCs"
slug: "npc-emotional-state"
personas: [P-002, P-003]
epic: "Dialogue Manager"
priority: "could-have"
complexity: "L"
tags: [dialogue-manager, emotion, npc, state-tracking, affective-computing]
---

# US-069: Emotional State Tracking for NPCs

## User Story

**As an** interactive fiction author (P-002),
**I want to** model NPC emotional states that evolve over the course of conversations and world events,
**So that** characters exhibit dynamic, contextually responsive affect rather than static personality templates.

## Acceptance Criteria

- [ ] Given an NPC registered with `emotional_state: {primary: "neutral", intensity: 0.5}`, when `dialogue_manager.set_emotion(npc_id, emotion="grief", intensity=0.9)` is called, then `dialogue_manager.get_emotion(npc_id)` returns `{primary: "grief", intensity: 0.9}`.
- [ ] Given an NPC in `"grief"` state with `intensity: 0.9`, when `speak()` is called, then the system prompt includes an emotional framing instruction (e.g., "You are deeply grieving. Let this shape your words without being melodramatic").
- [ ] Given `dialogue_manager.signal(event="ally_died", npc_id="bard_lyra")` called and the NPC having `emotional_triggers: [{event: "ally_died", emotion: "grief", intensity: 0.8}]`, when the signal fires, then `set_emotion("bard_lyra", "grief", 0.8)` is applied automatically.
- [ ] Given an NPC with `emotion_decay: {rate: 0.1, per: "turn"}`, when `speak()` is called 5 times after a grief event, then `get_emotion(npc_id).intensity` has decreased by approximately `5 * 0.1 = 0.5` from the initial value.
- [ ] Given `emotion_history_enabled: true` on the engine, when `dialogue_manager.emotion_history(npc_id)` is called, then it returns a list of `{emotion, intensity, timestamp}` entries in chronological order.
- [ ] Given an emotion intensity of 0.0 after decay, when `get_emotion(npc_id)` is called, then the state returns `{primary: "neutral", intensity: 0.0}` and no emotional framing is injected into the next `speak()` call.

## Notes

Dr. Okafor (P-003) is interested in this for affective NPC research. Emotional state is separate from disposition (US-063) — emotion is transient and event-driven, disposition is a long-term relational score. `L` complexity due to decay mechanics and event-trigger wiring.
