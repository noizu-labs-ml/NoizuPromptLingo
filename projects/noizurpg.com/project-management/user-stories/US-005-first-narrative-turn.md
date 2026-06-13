---
id: US-005
title: "Run first AI-generated narrative turn"
slug: "first-narrative-turn"
personas: [P-001, P-002]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "M"
tags: [narrative, llm, game-loop, interactive-fiction]
---

# US-005: Run First AI-Generated Narrative Turn

## User Story

**As an** indie AI game developer or interactive fiction author (P-001, P-002),
**I want to** submit a player action and receive an AI-generated narrative response that reflects the current world and character state,
**So that** I can verify the core game loop is functional and experience the quality of the AI narration firsthand.

## Acceptance Criteria

- [ ] Given a configured NoizuRPG project with at least one character and one world location, when I call `engine.process_turn(action="look around")`, then the method returns a `NarrativeTurn` object containing a non-empty `narrative_text` string.
- [ ] Given a `NarrativeTurn` response, when I inspect the object, then it contains `narrative_text`, `character_state_delta`, `world_state_delta`, and `timestamp` fields.
- [ ] Given a character with `name: "Aria"` and `location: "The Tavern"`, when I call `engine.process_turn(action="introduce yourself to the barkeep")`, then the returned `narrative_text` references the character's name and current location.
- [ ] Given a narrative turn call that results in a state change (e.g., picking up an item), when I inspect `character_state_delta`, then it contains the key-value pairs representing what changed on the character.
- [ ] Given a valid LLM configuration and a turn call, when the LLM API returns an error (e.g., rate limit), then `process_turn` raises an `LLMError` with the upstream error message rather than returning corrupt data.
- [ ] Given the CLI command `noizurpg play`, when I type a player action at the prompt, then the AI narrative response is printed to stdout within 30 seconds on a standard cloud LLM provider.

## Notes

This story represents the "aha moment" for both developers and authors. The narrative text quality depends on the LLM — NoizuRPG is responsible for prompt construction, not generation quality. Elena (P-002) will evaluate whether the prompt context sufficiently conveys tone and genre conventions from the world config. See US-022 for the character state injection into the narrative context.
