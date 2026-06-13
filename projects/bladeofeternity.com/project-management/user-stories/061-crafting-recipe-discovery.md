# US-061: Crafting Recipe Discovery

**Persona:** Dave — Sighted MUD Veteran
**Priority:** P1
**Epic:** Crafting System

## Story
As Dave, I want to discover new crafting recipes through experimentation, world exploration, and NPC interactions so that I can develop a sense of mastery over the crafting system and unlock economic advantages.

## Acceptance Criteria
- [ ] Recipe discovery is announced with descriptive text (e.g., "You combine copper ore and tin, and the familiar ring of alloying fills the forge — you have discovered Bronze Ingot.")
- [ ] Discovered recipes are saved to a personal recipe book accessible via `/recipes` or `RECIPES` command
- [ ] Recipe book supports filtering by material type, craft skill, and discovered/undiscovered status
- [ ] Some recipes are locked behind NPC quests, skill rank thresholds, or territorial access
- [ ] Screen reader output for recipe book uses a navigable list with item count announced (e.g., "Recipe book: 34 entries. Filter active: Smithing.")
- [ ] Experimenting with unknown combinations yields meaningful failure text, not silent no-op

## Notes
Discovery progression is a core retention loop. Experimentation should feel rewarding even on failure — "You attempt to combine iron and glass. The materials resist each other and shatter. You gain a small insight into metallurgical incompatibility." Consider a partial-discovery system where failed experiments accumulate toward revelation.
