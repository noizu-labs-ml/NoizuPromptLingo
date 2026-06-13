# US-177: Experience & Leveling System

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Tyler, I want to gain experience from combat, quests, crafting, and exploration that accumulates toward level-ups so that every activity I engage in advances my character and unlocks new content.

## Acceptance Criteria
- [ ] XP awarded from five activity types: combat kills (scaled by enemy level delta), quest completion (flat + bonus for optional objectives), crafting (per item, scaled by recipe complexity), exploration (first-visit discovery of named locations), and dungeon/event participation
- [ ] XP gains announced via polite ARIA live region immediately on award: "You gained 150 experience. 1,240 of 3,000 to level 8."
- [ ] Level-up triggers assertive ARIA announcement: "Level up! You are now level 8. You have 3 attribute points and 1 skill point to allocate."
- [ ] XP progress bar expressed as text ratio in SR output; visual progress bar present for sighted users with color and fill
- [ ] Level gates enforced server-side: areas, abilities, and equipment with level requirements inaccessible until threshold met, with clear SR messaging explaining the requirement
- [ ] XP curve follows tuned exponential formula documented in game design spec; curve adjustable via server config without client deploy
- [ ] Bonus XP modifiers (rested XP from inn stays, guild XP bonuses, seasonal events) displayed as multiplier in XP gain announcements: "You gained 300 experience (2x rested bonus)."
- [ ] XP and current level persisted in player state and included in character sheet and inspection panels

## Notes
Tyler's retention depends on the feedback loop feeling tight: action → reward → progress. The XP announcement cadence must be tuned — too frequent (every small hit) creates noise for SR users; too sparse loses the dopamine loop. Recommended: batch XP announcements at natural action boundaries (end of combat encounter, crafting completion, quest turn-in) rather than per-hit. The rested XP system from US-191 should feed a multiplier into this system. Level gates must explain *why* something is locked, not just refuse access — "This area requires level 10; you are level 7" rather than a silent block. XP curve should be publicly documented in-game so power users like Tyler can plan grinding sessions.
