---
id: US-013
title: "Track character relationships"
slug: "character-relationships"
personas: [P-001, P-002]
epic: "Character System"
priority: "must-have"
complexity: "M"
tags: [character, relationships, social, npc, narrative]
---

# US-013: Track Character Relationships

## User Story

**As an** indie AI game developer or interactive fiction author (P-001, P-002),
**I want to** define and query relationships between characters (e.g., ally, rival, neutral) with an optional affinity score,
**So that** the Narrative Engine and Dialogue Manager can generate contextually appropriate interactions based on how characters feel about each other.

## Acceptance Criteria

- [ ] Given two `Character` objects `aria` and `barkeep`, when I call `aria.relationships.add(target=barkeep, relation_type="acquaintance", affinity=0.3)`, then `aria.relationships.get(barkeep.id)` returns a `Relationship` object with `relation_type="acquaintance"` and `affinity=0.3`.
- [ ] Given a relationship with `affinity=0.3`, when I call `relationship.adjust_affinity(delta=0.2)`, then `relationship.affinity` becomes `0.5` (clamped to the range `[-1.0, 1.0]`).
- [ ] Given `aria` with a relationship to `barkeep`, when I call `aria.relationships.get_by_type("acquaintance")`, then the returned list includes `barkeep`'s relationship entry.
- [ ] Given a character with no relationships defined, when I call `character.relationships.all()`, then an empty list is returned without errors.
- [ ] Given a relationship defined from `aria` to `barkeep`, when I call `aria.relationships.remove(barkeep.id)`, then a subsequent `aria.relationships.get(barkeep.id)` raises `RelationshipNotFoundError`.
- [ ] Given a character with relationships, when I call `character.to_dict()`, then the relationships list is included with `target_id`, `relation_type`, and `affinity` fields for each entry.

## Notes

Relationships are directional by default — aria may view barkeep as an acquaintance while barkeep views aria as a suspicious stranger. The Narrative Engine (US-022) should inject the relationship context for the target NPC into prompts. Elena (P-002) requires the `relation_type` field to support custom string values beyond a fixed enum. See US-014 for the character knowledge system and US-013 as a dependency for the Dialogue Manager.
