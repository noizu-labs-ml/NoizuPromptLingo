---
id: US-064
title: "Dialogue Memory Across Sessions"
slug: "dialogue-memory"
personas: [P-001, P-004]
epic: "Dialogue Manager"
priority: "must-have"
complexity: "M"
tags: [dialogue-manager, memory, persistence, session, context]
---

# US-064: Dialogue Memory Across Sessions

## User Story

**As an** indie AI game developer (P-001),
**I want to** persist conversation history per NPC-player pair across game sessions,
**So that** NPCs remember prior interactions and can reference past events in new conversations.

## Acceptance Criteria

- [ ] Given a completed conversation between player P and NPC N stored via `dialogue_manager.save_conversation(npc_id, player_id, turns)`, when a new session begins and `speak()` is called, then the prior conversation turns are injected into the LLM context up to the configured `memory_window` turn count.
- [ ] Given a `memory_window: 10` configuration, when a player has 25 prior turns with an NPC, then only the 10 most recent turns are included in context; older turns are excluded.
- [ ] Given a conversation history for `(npc_id, player_id)` saved to a dict via `dialogue_manager.export_memory(npc_id, player_id)`, when `dialogue_manager.import_memory(data)` is called in a new engine instance, then `speak()` uses the imported history as if it were native.
- [ ] Given a `memory_window` of 0 configured, when `speak()` is called, then no conversation history is injected and the NPC responds without prior context.
- [ ] Given an NPC with conversation history, when `dialogue_manager.clear_memory(npc_id, player_id)` is called, then subsequent `speak()` calls inject no prior turns.
- [ ] Given two distinct `(npc_id, player_id)` pairs sharing the same `npc_id`, when memory is retrieved for one pair, then the other pair's conversation history is not included.

## Notes

Relates to US-074 (session persistence) in the Memory System epic — the Memory System may serve as the backing store for dialogue history. Sarah Kim (P-004) needs multi-session continuity for long-running tabletop campaigns spanning weeks.
