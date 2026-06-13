---
id: US-052
title: "Procedural Quest Generation from World State"
slug: "procedural-quest-gen"
personas: [P-001, P-003]
epic: "Quest Engine"
priority: "must-have"
complexity: "L"
tags: [quest-engine, procedural-generation, world-state, llm]
---

# US-052: Procedural Quest Generation from World State

## User Story

**As an** indie AI game developer (P-001),
**I want to** generate contextually appropriate quests from current world state using an LLM,
**So that** the game world produces emergent objectives without me hand-authoring every quest.

## Acceptance Criteria

- [ ] Given a `WorldState` snapshot and a `QuestEngine` with an LLM provider configured, when `quest_engine.generate(world_state, count=3)` is called, then it returns a list of 3 `QuestDefinition` objects each with valid `id`, `title`, `stages`, and at least one objective.
- [ ] Given a world state containing active factions and NPCs, when a quest is generated, then at least one quest objective references an entity (NPC name, location, or faction) present in the world state context passed to the LLM.
- [ ] Given a configured LLM provider that raises a timeout error, when `quest_engine.generate()` is called, then a `QuestGenerationError` is raised and no partial quests are returned.
- [ ] Given `generate()` called with `seed_tags=["combat", "rescue"]`, when the LLM prompt is constructed, then the seed tags are injected into the prompt and the returned quests have tags that include at least one of the seeds.
- [ ] Given `generate()` called with `temperature=0.0` on a deterministic model mock, when called twice with identical world state, then the returned quest definitions are structurally identical.
- [ ] Given generated quest JSON that fails schema validation, when `generate()` processes the LLM response, then it retries up to a configurable `max_retries` count before raising `QuestGenerationError`.

## Notes

Depends on US-051 for the `QuestDefinition` schema. Dr. Okafor (P-003) may extend this with custom generation strategies via a pluggable `QuestGenerator` protocol. World state context windowing should respect the LLM's context limit.
