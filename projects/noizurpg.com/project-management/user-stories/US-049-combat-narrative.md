---
id: US-049
title: "Combat narrative generation"
slug: "combat-narrative"
personas: [P-001]
epic: "Narrative Engine"
priority: "should-have"
complexity: "L"
tags: [narrative-engine, combat, generation, events, game-mechanics]
---

# US-049: Combat Narrative Generation

## User Story

**As a** indie AI game developer building an action RPG (P-001),
**I want to** pass a structured combat state (combatants, HP, actions taken this round) to the Narrative Engine and receive a prose description of the combat round,
**So that** mechanical combat outcomes are translated into vivid narrative without me writing a separate combat prose system.

## Acceptance Criteria

- [ ] Given a `CombatState` object with fields `attacker`, `defender`, `action`, `damage_dealt`, `defender_hp_remaining`, when I call `engine.generate_combat(combat_state)`, then a narrative string describing the round is returned.
- [ ] Given a combat state where `damage_dealt=0` (miss), when `engine.generate_combat()` is called, then the narrative describes a miss or dodge rather than a hit.
- [ ] Given a combat state where `defender_hp_remaining <= 0`, when `engine.generate_combat()` is called, then the narrative includes a defeat/death description appropriate to the combat style setting.
- [ ] Given a combat style configured as `"gritty"` vs `"heroic"`, when `engine.generate_combat()` is called, then the prose registers are stylistically distinct (e.g. gritty uses injury language; heroic uses triumph language).
- [ ] Given a multi-combatant round with three simultaneous actions, when `engine.generate_combat(combat_state)` is called with all actions, then a single cohesive narrative paragraph covering all three actions is returned (not three separate paragraphs concatenated).
- [ ] Given a combat narrative result, when `parse_events=True` is set, then any embedded status effect or HP-change events are extracted and returned in `NarrativeResult.events`.

## Notes

This story is large because multi-combatant narrative coherence and style variation require careful prompt design. P-001 needs this to avoid building a bespoke combat prose system. Combat style should be derivable from the narrative tone profile (US-044). Depends on US-041 (parse events) for event extraction.
