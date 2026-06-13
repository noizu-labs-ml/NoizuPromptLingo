---
id: US-014
title: "Manage character knowledge"
slug: "character-knowledge"
personas: [P-001, P-002]
epic: "Character System"
priority: "must-have"
complexity: "M"
tags: [character, knowledge, lore, memory, narrative]
---

# US-014: Manage Character Knowledge

## User Story

**As an** indie AI game developer or interactive fiction author (P-001, P-002),
**I want to** track what a character knows (facts, lore, secrets) and query that knowledge store,
**So that** the Narrative Engine can constrain AI responses to only reference information the character has actually learned during the game.

## Acceptance Criteria

- [ ] Given a `Character` object, when I call `character.knowledge.add(key="blacksmith_location", value="The forge is in the eastern district", source="innkeeper", turn=3)`, then `character.knowledge.get("blacksmith_location")` returns the stored `KnowledgeEntry` with all fields intact.
- [ ] Given a character knowledge store, when I call `character.knowledge.get("unknown_fact")`, then `None` is returned rather than raising an exception.
- [ ] Given a character with multiple knowledge entries, when I call `character.knowledge.filter(source="innkeeper")`, then only entries acquired from `"innkeeper"` are returned.
- [ ] Given a knowledge entry, when I call `character.knowledge.revoke("blacksmith_location")`, then a subsequent `character.knowledge.get("blacksmith_location")` returns `None`.
- [ ] Given a character's knowledge store, when I call `character.knowledge.as_context_string()`, then the method returns a formatted string listing all knowledge entries suitable for inclusion in an LLM prompt.
- [ ] Given a character with knowledge, when I call `character.to_dict()`, then all knowledge entries including `key`, `value`, `source`, and `turn` fields are present in the serialized output.

## Notes

Character knowledge is distinct from the Memory System (which tracks episodic narrative events at a session level). Knowledge here refers to factual beliefs the character holds about the world. Elena (P-002) needs `as_context_string()` output to be readable prose, not raw JSON, since it feeds directly into LLM prompts. See US-023 for the event history log and the Memory System component for session-level recall.
