---
id: US-034
title: "NPC population per location"
slug: "npc-population"
personas: [P-001, P-002]
epic: "World State Manager"
priority: "should-have"
complexity: "M"
tags: [world-state, locations, npcs, population]
---

# US-034: NPC Population per Location

## User Story

**As a** narrative designer building a living city (P-002),
**I want to** assign NPC characters to locations and move them between locations over time,
**So that** the Narrative Engine knows which characters are present in a scene and can include them in generated descriptions without manual scene setup.

## Acceptance Criteria

- [ ] Given a registered character and a registered location, when I call `world.place_character(character_id, location_id)`, then `world.characters_at(location_id)` returns a list containing that character ID.
- [ ] Given a character currently at location A, when I call `world.move_character(character_id, location_B)`, then `world.characters_at(location_A)` no longer includes the character and `world.characters_at(location_B)` does.
- [ ] Given a location with five NPCs present, when I call `world.characters_at(location_id, role="merchant")`, then only NPCs with `role="merchant"` are returned.
- [ ] Given a character with no assigned location, when I call `world.get_character_location(character_id)`, then `None` is returned without error.
- [ ] Given a location with present characters, when the Narrative Engine assembles scene context, then character names and brief roles are included in the location context block.

## Notes

Depends on US-026 (define locations). Character definitions are owned by the Character System; this story covers world-state placement only, not character attributes. P-002 uses population data to avoid writing characters into scenes where they physically cannot be.
