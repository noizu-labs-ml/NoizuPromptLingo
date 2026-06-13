---
id: US-020
title: "Define character archetypes as templates"
slug: "character-archetypes"
personas: [P-001, P-002, P-006]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [character, archetype, template, reusability, studio]
---

# US-020: Define Character Archetypes as Templates

## User Story

**As an** indie developer, interactive fiction author, or game studio lead (P-001, P-002, P-006),
**I want to** define character archetypes (e.g., "Warrior", "Mage", "Rogue") as reusable templates with default stats and traits,
**So that** I can quickly instantiate consistent character types without duplicating configuration across every character file.

## Acceptance Criteria

- [ ] Given an archetype YAML file `archetypes/warrior.yaml` defining default `stats`, `traits`, and `starting_inventory`, when I call `Character.from_archetype("archetypes/warrior.yaml", name="Gareth")`, then the returned character has all archetype defaults populated and `name` set to `"Gareth"`.
- [ ] Given a character instantiated from an archetype, when I override a stat at creation time via `Character.from_archetype("archetypes/warrior.yaml", name="Gareth", stats={"strength": 18})`, then the overridden value `18` is used instead of the archetype default, and all other stats retain archetype defaults.
- [ ] Given a project with an `archetypes/` directory, when I call `Archetype.list()`, then all `.yaml` files in that directory are returned as available archetype names.
- [ ] Given an archetype that extends another via `extends: "archetypes/base_humanoid.yaml"`, when I instantiate a character from the extending archetype, then it inherits all base archetype fields and the extending archetype's fields take precedence on conflicts.
- [ ] Given a studio with 50+ characters, when I update `archetypes/warrior.yaml` with a new default trait, then existing characters instantiated from that archetype are not retroactively changed — archetypes are applied at instantiation time only.

## Notes

Aisha (P-006) needs archetypes to enable rapid NPC generation at scale for a commercial game with hundreds of characters. Elena (P-002) needs narrative trait defaults in archetypes to establish consistent voice and personality baselines per character class. The `extends` inheritance chain must detect circular dependencies and raise a `CircularArchetypeError`. See US-011 for the base character definition and US-020 as a dependency for party generation in US-024.
