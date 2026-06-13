---
id: US-061
title: "Define NPC Voice Profiles"
slug: "npc-voice-profiles"
personas: [P-001, P-002]
epic: "Dialogue Manager"
priority: "must-have"
complexity: "M"
tags: [dialogue-manager, npc, voice, persona, prompt-engineering]
---

# US-061: Define NPC Voice Profiles

## User Story

**As an** indie AI game developer (P-001),
**I want to** define structured voice profiles for NPCs that shape how the LLM generates their dialogue,
**So that** each character speaks in a consistent, distinct voice without me embedding raw system prompts in game logic.

## Acceptance Criteria

- [ ] Given a voice profile dict with `id`, `name`, `tone`, `speech_patterns`, and `vocabulary_level` fields, when `DialogueManager.register_npc(profile)` is called, then the NPC is stored and retrievable by `id` without error.
- [ ] Given a registered NPC with `tone: "gruff"` and `speech_patterns: ["uses archaic contractions", "avoids pleasantries"]`, when `dialogue_manager.speak(npc_id, prompt="greet the player")` is called, then the system prompt sent to the LLM includes the tone and speech pattern instructions.
- [ ] Given two NPCs with different voice profiles, when `speak()` is called for each with identical user input, then the LLM prompts differ in their NPC-specific instructions, producing distinguishably different character voices.
- [ ] Given a voice profile with `example_phrases: ["By the Forge!", "Steel and stone!"]`, when `speak()` constructs the system prompt, then the example phrases are included as few-shot demonstrations.
- [ ] Given a voice profile missing the required `id` field, when `register_npc()` is called, then a `VoiceProfileError` is raised before any LLM call is made.
- [ ] Given an NPC profile updated via `dialogue_manager.update_npc(npc_id, tone="warm")`, when `speak()` is subsequently called for that NPC, then the updated tone is reflected in the LLM system prompt.

## Notes

Foundation story for the Dialogue Manager epic. Elena Vasquez (P-002) needs rich narrative persona control; voice profiles are the primary lever. US-063 (disposition model) and US-069 (emotional state) extend the profile at runtime.
