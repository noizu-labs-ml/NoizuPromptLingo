---
id: US-018
title: "Perform skill checks with dice systems"
slug: "skill-checks"
personas: [P-001, P-004]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [character, skill-check, dice, mechanics, randomness]
---

# US-018: Perform Skill Checks with Dice Systems

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** perform dice-based skill checks against character stats using configurable dice systems,
**So that** I can implement classic RPG mechanics (pass/fail, degrees of success) that integrate naturally with the Narrative Engine.

## Acceptance Criteria

- [ ] Given a character with `stats["dexterity"] = 14` and a D&D 5e-style check, when I call `character.skill_check(stat="dexterity", difficulty=12, dice="1d20")`, then the method returns a `SkillCheckResult` with `roll` (int), `modifier` (int), `total` (int), `difficulty` (int), and `success` (bool) fields.
- [ ] Given a `SkillCheckResult`, when `total >= difficulty`, then `result.success` is `True`; when `total < difficulty`, then `result.success` is `False`.
- [ ] Given a `dice` parameter of `"2d6"`, when I perform a skill check, then `result.roll` is the sum of two random integers each in the range `[1, 6]`.
- [ ] Given a custom dice resolver registered via `register_dice_system("fate", fate_dice_fn)`, when I call `character.skill_check(dice="fate")`, then the custom resolver function is called with the character and stat as arguments.
- [ ] Given a skill check call, when I pass `seed=42` for deterministic testing, then the same roll value is produced across multiple calls with the same seed.
- [ ] Given a `SkillCheckResult`, when I pass it to `engine.process_turn(action="pick the lock", check_result=result)`, then the narrative response references whether the attempt succeeded or failed.

## Notes

Sarah (P-004) needs this to replicate the feel of physical tabletop play where dice outcomes drive narrative. The dice notation string (e.g., `"2d6+3"`, `"1d20"`) should follow standard RPG convention. The integration with `process_turn` (US-005) is essential — the check result must influence the LLM prompt construction in the Narrative Engine. See US-017 for the stat schema that defines which stats are check-eligible.
