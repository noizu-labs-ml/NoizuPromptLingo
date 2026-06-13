---
id: US-071
title: "Append-Only Event Journal"
slug: "event-journal"
personas: [P-001]
epic: "Memory System"
priority: "must-have"
complexity: "M"
tags: [memory-system, event-journal, append-only, audit-log]
---

# US-071: Append-Only Event Journal

## User Story

**As an** indie AI game developer (P-001),
**I want to** record all significant game events to an append-only journal,
**So that** I have a durable, ordered history of everything that happened in a session that other components can query for context.

## Acceptance Criteria

- [ ] Given a `MemorySystem` instance, when `memory.record(event_type="npc_killed", data={"npc_id": "guard_1", "killer": "player"}, session_id="s1")` is called, then the event is stored with an auto-assigned `event_id`, `timestamp`, `session_id`, and the supplied `event_type` and `data`.
- [ ] Given three events recorded in sequence, when `memory.events(session_id="s1")` is called, then the returned list contains all three events in insertion order with no gaps.
- [ ] Given a recorded event retrieved by `event_id`, when `memory.get_event(event_id)` is called, then the returned event dict exactly matches the original `event_type`, `data`, and `timestamp` without mutation.
- [ ] Given an attempt to delete or overwrite an existing event via any public API method, then a `JournalImmutabilityError` is raised; no deletion or update method exists on the public interface.
- [ ] Given 10,000 events recorded for a session, when `memory.events(session_id="s1", limit=100, offset=0)` is called, then exactly 100 events are returned starting from the oldest, and `offset=100` returns the next 100.
- [ ] Given `memory.record()` called without a `session_id`, when the call executes, then a `MissingSessionError` is raised before the event is stored.

## Notes

Foundation story for the Memory System epic. US-072 (compression), US-073 (relevance retrieval), and US-075 (semantic search) all read from this journal. The append-only constraint is critical for audit integrity and LLM context reconstruction.
