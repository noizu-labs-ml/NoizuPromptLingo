---
id: US-011
title: "Define character with stat block"
slug: "define-character-stats"
personas: [P-001, P-002]
epic: "Character System"
priority: "must-have"
complexity: "S"
tags: [character, stats, definition, yaml, schema]
---

# US-011: Define Character with Stat Block

## User Story

**As an** indie AI game developer or interactive fiction author (P-001, P-002),
**I want to** define a character's core attributes and stats in YAML or via Python code,
**So that** I have a structured data model that the Narrative Engine and other components can reference when generating content.

## Acceptance Criteria

- [ ] Given a YAML character definition with `name`, `description`, `stats` (key-value pairs), and `traits` (list of strings), when I load it with `Character.from_yaml("characters/aria.yaml")`, then the returned `Character` object exposes all fields as typed attributes.
- [ ] Given a `Character` object, when I access `character.stats["strength"]`, then the value is returned as the declared type (int, float, or string) without casting errors.
- [ ] Given a `Character` defined in Python using `Character(name="Aria", stats={"strength": 10, "dexterity": 14})`, when I call `character.to_dict()`, then the output dictionary matches the field structure expected by `Character.from_dict()`.
- [ ] Given a YAML character definition with a required field (`name`) missing, when I call `Character.from_yaml()`, then a `CharacterValidationError` is raised listing the missing required fields.
- [ ] Given a character with a numeric stat, when I set `character.stats["health"] = 50` and then call `character.stats["health"]`, then the updated value `50` is returned.

## Notes

This is the foundational story for the Character System epic — all other character stories depend on this data model being stable. Elena (P-002) needs the `traits` list to support free-text strings that the Narrative Engine can incorporate into prompts. See US-017 for custom stat system configuration and US-015 for serialization.
