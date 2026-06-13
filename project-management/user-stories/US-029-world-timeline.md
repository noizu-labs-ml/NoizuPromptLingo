---
id: US-029
title: "Track world timeline"
slug: "world-timeline"
personas: [P-001, P-004]
epic: "World State Manager"
priority: "should-have"
complexity: "M"
tags: [world-state, timeline, history, events]
---

# US-029: Track World Timeline

## User Story

**As a** tabletop GM converting campaigns to digital (P-004),
**I want to** record world events on an in-game timeline with timestamps and tags,
**So that** the narrative engine and LLM prompts can reference historical context and maintain temporal consistency across sessions.

## Acceptance Criteria

- [ ] Given an in-game calendar tick, when I call `world.timeline.record(tick, event_id, description, tags=[])`, then the event is persisted and queryable.
- [ ] Given a populated timeline, when I call `world.timeline.query(before=tick, tags=["war"])`, then only events with the "war" tag occurring before the given tick are returned in chronological order.
- [ ] Given a timeline with 50 events, when I call `world.timeline.recent(n=5)`, then the 5 most recent events are returned sorted newest-first.
- [ ] Given a world state with a timeline, when I serialize and deserialize it via `world.to_dict()` / `World.from_dict()`, then all timeline events are preserved with identical data.
- [ ] Given a timeline context request, when the Narrative Engine assembles a prompt, then it can include a configurable window of recent timeline events without exceeding the token budget.

## Notes

Designed to satisfy P-004's need to replicate campaign chronicles digitally. Integrates with US-036 (branching timelines) for multi-branch support and US-031 (world snapshots) for save/load of timeline state.
