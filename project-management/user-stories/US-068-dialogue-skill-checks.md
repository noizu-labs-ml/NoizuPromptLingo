---
id: US-068
title: "Dialogue Skill Check Integration"
slug: "dialogue-skill-checks"
personas: [P-001, P-004]
epic: "Dialogue Manager"
priority: "should-have"
complexity: "M"
tags: [dialogue-manager, skill-checks, persuasion, dice, ttrpg]
---

# US-068: Dialogue Skill Check Integration

## User Story

**As an** indie AI game developer (P-001),
**I want to** attach skill check results to dialogue prompts so NPC responses reflect success or failure outcomes,
**So that** social skill mechanics (Persuasion, Intimidation, Deception) have tangible narrative effects on NPC dialogue.

## Acceptance Criteria

- [ ] Given `speak(npc_id, player_id, prompt="Convince the guard to stand aside", skill_check={"skill": "persuasion", "result": "success", "margin": 8})`, when the LLM call is made, then the system prompt instructs the NPC to respond as if successfully persuaded, proportional to the margin.
- [ ] Given a skill check result of `"failure"` with `margin: -3`, when `speak()` generates the NPC response, then the system prompt directs the NPC to resist or react negatively, with severity scaled to the failure margin.
- [ ] Given a skill check result of `"critical_success"`, when `speak()` runs, then the system prompt includes a critical success framing and `dialogue_manager.adjust_disposition(npc_id, player_id, delta=+15)` is called automatically.
- [ ] Given a skill check result of `"critical_failure"`, when `speak()` runs, then `adjust_disposition(npc_id, player_id, delta=-15)` is called automatically and the NPC response reflects strong negative reaction.
- [ ] Given `speak()` called without a `skill_check` argument, when the call executes, then it proceeds normally with no skill check framing in the prompt.
- [ ] Given a skill check with an unrecognized `result` value (not in `{success, failure, critical_success, critical_failure}`), when `speak()` is called, then a `SkillCheckError` is raised before the LLM call.

## Notes

Sarah Kim (P-004) requires this for tabletop-style social encounters. Disposition side-effects on critical outcomes link to US-063. The `margin` field is optional but enables graduated response framing when provided.
