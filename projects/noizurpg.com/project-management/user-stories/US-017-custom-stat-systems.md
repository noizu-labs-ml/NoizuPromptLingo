---
id: US-017
title: "Configure custom stat systems"
slug: "custom-stat-systems"
personas: [P-001, P-007]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [character, stats, customization, schema, extensibility]
---

# US-017: Configure Custom Stat Systems

## User Story

**As an** indie AI game developer or community contributor (P-001, P-007),
**I want to** define a custom stat schema for my game (e.g., D&D 5e, FATE, custom fantasy) via configuration rather than code changes,
**So that** I can adapt the Character System to any RPG ruleset without forking the framework.

## Acceptance Criteria

- [ ] Given a `stat_schema.yaml` defining stats with names, types, min/max values, and default values, when I load it with `StatSchema.from_file("stat_schema.yaml")` and create a character, then the character validates all stat values against the schema on assignment.
- [ ] Given a stat schema with `strength: {type: int, min: 1, max: 20, default: 10}`, when I try to set `character.stats["strength"] = 25`, then a `StatValidationError` is raised with the message "strength value 25 exceeds maximum of 20".
- [ ] Given a stat schema with a required stat `mana`, when I create a `Character` without providing `mana`, then the character is initialized with the schema-defined default value rather than raising an error.
- [ ] Given a project-level `config.yaml` with `character.stat_schema: "schemas/dnd5e.yaml"`, when I initialize the framework, then all characters created in the session use the D&D 5e stat schema automatically.
- [ ] Given a custom stat schema defining a `sanity` stat with `type: float`, when I call `character.stats["sanity"] = 0.75`, then the value is stored as a float and returned as a float.
- [ ] Given no stat schema is configured, when I create a character with arbitrary stat keys and values, then the framework accepts any string keys with any int, float, or string values (permissive default mode).

## Notes

Ryan (P-007) may contribute community stat schema presets (D&D 5e, Pathfinder, FATE) to the project's schema registry. The permissive default mode (no schema) is critical for rapid prototyping. Validation should be opt-in, not a prerequisite for getting started. See US-011 for the base character stat story and US-018 for skill checks that operate against these stats.
