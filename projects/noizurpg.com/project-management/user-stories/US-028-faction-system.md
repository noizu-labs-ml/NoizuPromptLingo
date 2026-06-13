---
id: US-028
title: "Create faction system"
slug: "faction-system"
personas: [P-001, P-002]
epic: "World State Manager"
priority: "must-have"
complexity: "M"
tags: [world-state, factions, relationships, politics]
---

# US-028: Create Faction System

## User Story

**As a** indie AI game developer (P-001),
**I want to** define factions with reputations, inter-faction relationships, and membership rules,
**So that** characters and NPCs can belong to factions whose standings dynamically influence dialogue, quest availability, and narrative tone.

## Acceptance Criteria

- [ ] Given a faction definition with `id`, `name`, and optional `description`, when I call `world.add_faction(**props)`, then it is stored and retrievable without error.
- [ ] Given two registered factions, when I call `world.set_faction_relation(A, B, value=0.8)`, then `world.get_faction_relation(A, B)` returns `0.8` (range -1.0 to 1.0, where -1 is hostile and 1 is allied).
- [ ] Given a character with `faction_id` set, when I call `world.get_faction_members(faction_id)`, then that character's ID appears in the returned list.
- [ ] Given a faction with `reputation_thresholds` defining labels (e.g. `{"hostile": -0.5, "neutral": 0.0, "friendly": 0.5}`), when I call `world.reputation_label(faction_id, score=-0.6)`, then `"hostile"` is returned.
- [ ] Given a world context assembly, when factions relevant to the player's current location are present, then faction names, relations, and the player's standing are included in the context payload.

## Notes

Faction relations will feed directly into the Dialogue Manager (future epic) for NPC attitude. Narrative designers like P-002 can use faction membership to encode political texture in prose prompts. Related to US-035 (world event triggers) which may shift faction relations.
