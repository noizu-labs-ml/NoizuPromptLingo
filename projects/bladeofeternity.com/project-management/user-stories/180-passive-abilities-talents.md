# US-180: Passive Abilities & Talents

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Tyler, I want passive abilities that permanently modify my character's behavior — such as auto-dodge chance, crafting bonuses, and haggling discounts — so that my build choices have persistent mechanical identity beyond active skill usage.

## Acceptance Criteria
- [ ] Passive abilities are a distinct node type in the skill tree (US-179), visually and semantically differentiated from active abilities; SR announces node type as "passive talent" on focus
- [ ] Passives take effect immediately on investment with no activation required; effect described in present tense in node description ("You have a 12% chance to automatically dodge the next incoming melee attack each combat round")
- [ ] All active passives listed in character sheet under a dedicated "Passive Talents" section with current effect values, navigable by keyboard and fully SR-readable
- [ ] Passives stack additively with other passives of the same type up to a documented cap; stacking formula and cap displayed in passive description
- [ ] Passives interact correctly with active abilities (e.g., a passive increasing critical strike chance applies to both auto-attacks and active skill crits); interactions documented in ability text
- [ ] Passive effects reflected in derived stat recalculation: auto-dodge chance appears in character sheet Agility section as a derived stat with source attribution ("12% auto-dodge from Shadowstep Instinct")
- [ ] Passive abilities cannot be directly activated or toggled; any passive with a conditional trigger clearly describes its trigger condition in SR-readable text

## Notes
Passives are the "set it and forget it" layer of character identity — they run in the background and make Tyler's Rogue feel different from another Rogue even when using identical active abilities. The source attribution in derived stats (e.g., "12% auto-dodge from Shadowstep Instinct") is essential for Marcus and other blind players to understand *why* their numbers look the way they do. Without attribution, stat sheets become opaque. The no-toggle constraint keeps SR output clean during combat — there is no "activate passive" cognitive burden. Stacking caps prevent passive-stacking exploits while keeping Dave happy with the complexity of multi-class dabbling (US-182). Consider a "passive summary" voice shortcut that reads all active passives aloud in a single announcement for quick pre-combat review.
