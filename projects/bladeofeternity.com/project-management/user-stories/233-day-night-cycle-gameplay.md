# US-233: Day-Night Cycle and Gameplay

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Marcus, I want day and night to create genuinely different gameplay conditions — different enemies, stealth bonuses, and danger levels — so that time of day is a tactical variable I can optimize for PvP and farming strategies.

## Acceptance Criteria
- [ ] Day/night cycle runs at a configurable ratio to real time (default: 1 game hour = 5 real minutes, full cycle = 2 real hours); server-synchronized so all players share the same time
- [ ] Night gameplay differences: nocturnal creature spawns (wolves, undead, shadow-type enemies), increased encounter frequency, stealth bonus (+20% stealth effectiveness), increased PvP aggressor penalty reduction
- [ ] Daytime gameplay differences: merchant availability, guard presence (increased safety in settlements), diurnal creature activity, quest-relevant daytime NPCs accessible
- [ ] Night narration via non-visual senses exclusively: temperature drop, owl calls, cricket sounds, distant wolf howl, complete absence of market noise, torch-lit warmth from inn windows described as sound and heat emanating from nearby light
- [ ] Dawn and dusk transitions narrated as atmospheric events: "The eastern sky shifts — birdsong begins in the trees, and the market square stirs to life as shutters creak open"
- [ ] Time of day accessible at any moment via status query: "Late evening. Second moon rise in approximately 30 minutes." — expressed in game-world terms, not real time
- [ ] Night bonus announced to player on first night login each session: "Night has fallen — your shadow skills are sharpened. Nocturnal creatures stalk the wilderness."
- [ ] Player-settable time reminders: "Alert me when dawn approaches" triggers a warning 5 game-minutes before sunrise; accessible without leaving current activity

## Notes
Marcus will exploit the night bonus for his stealth PvP builds — this is exactly the intended behavior. The tactical dimension of time is what makes the day/night cycle meaningful rather than cosmetic. The 2-real-hour cycle is fast enough to experience multiple cycles per session but slow enough that a night period lasts a meaningful game duration. Server synchronization is critical: if Marcus and Tyler are in the same world, they must share the same time state. Night narration through non-visual senses is the core accessibility requirement: moonrise described as "the ambient sounds of night shifting, the temperature dropping further" rather than "the sky darkens to deep blue" is both more accessible and more evocative. The time-in-game-world format ("Second moon rise in approximately 30 minutes") maintains fiction rather than exposing real-time mechanics. Player-settable reminders are a practical feature for Marcus who may be in a dungeon and wants to surface before dawn to make use of night mechanics. The dawn narration as an atmospheric event (birdsong, shutters, market stirring) is a world-building moment that rewards players who experience the transition rather than sleeping through it.
