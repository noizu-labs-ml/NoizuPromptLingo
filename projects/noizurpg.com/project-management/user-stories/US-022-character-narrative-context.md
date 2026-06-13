---
id: US-022
title: "Access character state from narrative context"
slug: "character-narrative-context"
personas: [P-001, P-003]
epic: "Character System"
priority: "must-have"
complexity: "M"
tags: [character, narrative, context, llm, prompt-engineering]
---

# US-022: Access Character State from Narrative Context

## User Story

**As an** indie AI game developer or AI/ML researcher (P-001, P-003),
**I want to** have the character's current state (stats, inventory, relationships, knowledge) automatically injected into the Narrative Engine's LLM prompt context,
**So that** AI-generated narrative responses are grounded in the character's actual situation rather than hallucinating inconsistent details.

## Acceptance Criteria

- [ ] Given a character with `name="Aria"`, `location="The Tavern"`, and `stats["health"]=45`, when `engine.process_turn(character=aria, action="look around")` is called, then the LLM prompt includes a structured character context block containing name, location, and current health.
- [ ] Given a character context block injected into the prompt, when I inspect the raw prompt via `engine.last_prompt`, then the character's `effective_stats` (not base stats) are used in the context block.
- [ ] Given a character with 20+ inventory items, when the context is built, then the inventory summary is truncated to the most recently acquired or equipped items with a count of total items to stay within a configurable token budget.
- [ ] Given a character with relationships to an NPC named "Barkeep", when the narrative involves the barkeep, then the character's relationship type and affinity score for the barkeep are included in the context block.
- [ ] Given a `context_config.yaml` with `max_knowledge_entries: 5`, when the character has 10 knowledge entries, then only the 5 most recently acquired entries are included in the prompt context.
- [ ] Given a researcher (P-003) who wants to inspect the full prompt, when they call `engine.build_context(character=aria)`, then the method returns the complete context dictionary before LLM submission, without making an LLM call.

## Notes

This story is the integration point between the Character System and the Narrative Engine — it is the mechanism by which character data shapes AI output. James (P-003) needs `build_context()` as a research affordance to study how different character states influence narrative generation. Token budget management is critical for cost control on cloud LLM providers. See US-014 for knowledge management and US-013 for relationships.
