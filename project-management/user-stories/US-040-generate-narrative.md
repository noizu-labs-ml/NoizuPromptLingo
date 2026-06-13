---
id: US-040
title: "Generate narrative from player action"
slug: "generate-narrative"
personas: [P-001, P-002]
epic: "Narrative Engine"
priority: "must-have"
complexity: "M"
tags: [narrative-engine, generation, llm, player-action]
---

# US-040: Generate Narrative from Player Action

## User Story

**As a** indie AI game developer (P-001),
**I want to** pass a player action to the Narrative Engine and receive a narrative response grounded in current world state,
**So that** the core game loop — player acts, world responds — is implemented with a single API call without manual prompt construction.

## Acceptance Criteria

- [ ] Given a player action string and a configured world state, when I call `engine.generate(action="I open the chest")`, then a non-empty narrative string is returned describing the outcome.
- [ ] Given a world state with the player in location "dungeon_level_2", when `engine.generate()` is called, then the assembled prompt includes location context from the World State Manager for "dungeon_level_2".
- [ ] Given an LLM adapter configured for the engine, when `engine.generate()` is called, then the LLM is invoked exactly once per call (no hidden retry loops at this layer).
- [ ] Given an action result containing structured events (e.g. item acquired, HP change), when `engine.generate()` is called with `parse_events=True`, then a `NarrativeResult` is returned with both `narrative` text and a parsed `events` list.
- [ ] Given a narrative generation call, when it completes, then the interaction is appended to the engine's conversation history for future context assembly.

## Notes

This is the primary entry point to the Narrative Engine and the most developer-visible API. P-002 will rely on this story's reliability to drive IF branching. Depends on US-039 (token budget context assembly) and US-041 (event parsing). Related to US-048 (narrative coherence across turns).
