# US-026: Whirlwind Skill — AoE Combat Narration for Multiple Targets

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Combat — Skills

## Story
As Marcus, I want the Whirlwind skill's multi-target results narrated in a structured, non-overwhelming sequence so that I can track damage to each enemy and understand the tactical outcome without losing my place in the combat log.

## Acceptance Criteria
- [ ] Whirlwind available at skill rank 4, appearing in the Skills submenu with unlock requirement shown
- [ ] Activation narration sets the scene: "You drop your center of gravity, extend the blade, and spin — a full revolution that clears the space around you."
- [ ] Each struck target announced sequentially in a single prose block: no individual DOM mutations per target
- [ ] Target list ordered by proximity (closest first) with each entry: name, hit location, damage, resulting status
- [ ] Missed targets included: "Gareth steps back out of reach — the arc passes a finger's width from his chest."
- [ ] Total round summary follows individual target breakdown: "Three struck, one evaded, one out of range."
- [ ] Screen reader pause strategy: use comma-separated prose, not line breaks, within a single `aria-live` injection to prevent NVDA splitting into multiple utterances
- [ ] Whirlwind cooldown (3 rounds) announced after execution with round countdown

## Notes
AoE skills are the hardest narration problem in the game. A 5-target Whirlwind generates 5 collision events, 5 damage calculations, and up to 5 status effects. The prose pipeline must reduce this to one coherent paragraph. Vary sentence structure across rounds to prevent the narration from feeling mechanical. Consider a "tactical digest" mode that lists targets as a table-like structure for power users.
