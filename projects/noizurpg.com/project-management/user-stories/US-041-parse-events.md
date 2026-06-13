---
id: US-041
title: "Parse structured events from LLM output"
slug: "parse-events"
personas: [P-001]
epic: "Narrative Engine"
priority: "must-have"
complexity: "L"
tags: [narrative-engine, parsing, events, structured-output, llm]
---

# US-041: Parse Structured Events from LLM Output

## User Story

**As a** indie AI game developer (P-001),
**I want to** instruct the LLM to embed structured event markers in its narrative output and have the engine extract them into typed event objects,
**So that** game state mutations (damage dealt, items gained, quests triggered) can be applied programmatically from narrative text without writing fragile regex scrapers.

## Acceptance Criteria

- [ ] Given an LLM response containing a fenced JSON block `<event>{"type": "item_acquired", "item_id": "sword_01"}</event>`, when `engine.parse_events(response)` is called, then an `ItemAcquiredEvent` object is returned with `item_id="sword_01"`.
- [ ] Given an LLM response with multiple embedded event blocks, when `engine.parse_events(response)` is called, then all events are extracted and returned as an ordered list.
- [ ] Given an LLM response with a malformed event block (invalid JSON), when `engine.parse_events(response)` is called, then a `ParseWarning` is logged and the malformed block is skipped rather than raising an exception.
- [ ] Given a registered event schema for `"combat_damage"` with required fields `target` and `amount`, when a parsed event is missing `amount`, then a `EventValidationError` is raised identifying the missing field.
- [ ] Given a parsed event list, when I call `engine.apply_events(events, world)`, then each event mutates world state according to its type (e.g. `item_acquired` adds item to character inventory).
- [ ] Given narrative text with no embedded events, when `engine.parse_events(response)` is called, then an empty list is returned without error.

## Notes

This is a large story because it encompasses prompt engineering for event embedding, a parser for extracting events from mixed narrative/structured text, schema validation, and world state application. Depends on US-030 (world rules) for validating event applicability. Related to US-042 (response schemas).
