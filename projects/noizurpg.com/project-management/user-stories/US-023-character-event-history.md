---
id: US-023
title: "Character event history log"
slug: "character-event-history"
personas: [P-001, P-003]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [character, events, history, log, audit, research]
---

# US-023: Character Event History Log

## User Story

**As an** indie AI game developer or AI/ML researcher (P-001, P-003),
**I want to** access a chronological log of all significant events that have affected a character during a session,
**So that** I can debug game logic, audit state changes, and use event history as context for AI-driven narrative recall.

## Acceptance Criteria

- [ ] Given a character who gains XP, picks up an item, and completes a quest turn, when I call `character.event_history.all()`, then all three events are returned in chronological order with `event_type`, `description`, `timestamp`, and `turn_number` fields.
- [ ] Given the event history, when I call `character.event_history.filter(event_type="stat_change")`, then only stat change events are returned.
- [ ] Given `character.event_history.filter(since_turn=5)`, when there are 10 turns of events, then only events from turn 5 onward are returned.
- [ ] Given a state mutation such as `character.stats["health"] = 30` (previously `50`), when the mutation occurs, then a `stat_change` event is automatically appended to `event_history` with `stat="health"`, `old_value=50`, `new_value=30`.
- [ ] Given a researcher (P-003) who wants to export all events for analysis, when I call `character.event_history.to_jsonl("events.jsonl")`, then each event is written as a newline-delimited JSON record to the specified file.
- [ ] Given a configurable `max_event_history: 500` in `config.yaml`, when the event log exceeds 500 entries, then the oldest entries are dropped (FIFO) to keep the log within the limit.

## Notes

The event history serves a dual purpose: developer debugging (Marcus, P-001) and AI research (James, P-003). James may use event streams to study how character state evolution correlates with narrative coherence over long sessions. The automatic mutation tracking (criterion 4) requires instrumented setters on `stats`, `inventory`, `relationships`, and `knowledge`. See US-014 for knowledge and US-022 for how history may feed into narrative context.
