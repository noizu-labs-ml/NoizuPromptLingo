---
id: US-019
title: "Track character progression/XP"
slug: "character-progression"
personas: [P-001, P-004]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [character, progression, xp, leveling, advancement]
---

# US-019: Track Character Progression/XP

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** award experience points to a character and trigger level-up events when thresholds are crossed,
**So that** I can implement character advancement systems where player actions lead to measurable growth.

## Acceptance Criteria

- [ ] Given a `Character` object with `progression.level = 1` and `progression.xp = 0`, when I call `character.progression.award_xp(150)`, then `character.progression.xp` becomes `150`.
- [ ] Given an XP threshold of `100` for level 2, when `character.progression.xp` reaches or exceeds `100` via `award_xp()`, then `character.progression.level` increments to `2` and a `LevelUpEvent` is emitted.
- [ ] Given a `LevelUpEvent`, when I register a callback with `character.progression.on_level_up(my_callback)`, then `my_callback(event)` is called with the event containing `old_level`, `new_level`, `character_id`, and `timestamp`.
- [ ] Given a progression config with `xp_thresholds: [100, 300, 600, 1000]`, when I load it, then leveling up requires 100 XP for level 2, 300 total for level 3, 600 total for level 4, etc.
- [ ] Given a character at max level (as defined by the progression config), when I call `award_xp(500)`, then XP accumulates but `level` does not increment beyond the configured maximum and no `LevelUpEvent` is emitted.
- [ ] Given a character with progression data, when I call `character.to_dict()`, then `progression.level`, `progression.xp`, and `progression.xp_thresholds` are all present in the output.

## Notes

The XP threshold configuration should be part of the stat schema or a separate `progression.yaml` to allow different systems (flat increments, D&D-style exponential curves, FATE-style milestone advancement). Sarah (P-004) needs the level-up callback to be hookable so she can trigger stat increases and narrative announcements automatically. See US-017 for custom stat systems that progression may unlock.
