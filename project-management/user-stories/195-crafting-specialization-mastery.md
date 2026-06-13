# US-195: Crafting Specialization & Mastery

**Persona:** Dave — MUD veteran sysadmin who craves deep systems mastery
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Dave, I want a crafting mastery progression separate from my combat class that advances through apprentice to master tiers — unlocking better recipes, quality bonuses, and unique abilities — so that I can build a character identity centered on crafting excellence rather than combat dominance.

## Acceptance Criteria
- [ ] Crafting mastery tracked per discipline (Blacksmithing, Alchemy, Leatherworking, Enchanting, Cooking) with independent progression from combat level; disciplines level from 1 to 100 via crafting XP
- [ ] Five mastery tiers at defined thresholds: Apprentice (1-24), Journeyman (25-49), Artisan (50-74), Expert (75-89), Master (90-100); tier advancement triggers polite ARIA: "Your Blacksmithing has reached Artisan rank."
- [ ] Higher mastery unlocks: additional recipe slots, quality tier bonuses (Master crafters have 20% chance to produce Superior quality items), material efficiency improvements, and discipline-unique abilities (e.g., Master Enchanter: enchant items beyond their normal slot limit once per day)
- [ ] Crafting mastery displayed in character sheet as a dedicated section below combat stats; SR reads each discipline as "Blacksmithing: Artisan (rank 67 of 100)"
- [ ] Crafting mastery progression independent of combat class: a Warrior can be a Master Alchemist; no class gates on crafting disciplines; multi-discipline investment is possible but diluted (XP costs scale with number of active disciplines)
- [ ] Recipe discovery system: Artisan+ crafters can experiment with material combinations to discover previously unknown recipes; failed experiments consume materials but generate partial mastery XP
- [ ] Crafting mastery visible in character inspection panel (US-196) as discipline summary; other players can see crafting tier to commission work
- [ ] Master crafters visible in a server-wide Master Crafters registry accessible via in-game menu; players can search by discipline and send commission requests

## Notes
Dave has spent decades mastering complex systems in real life (sysadmin) and games (MUD veteran). Crafting mastery gives him a progression path that doesn't require combat reflexes — he can be the most respected person on the server without ever winning a PvP duel. The independent mastery progression is the key design principle: crafting should feel like a parallel game, not a side quest for combat characters. The Master Crafters registry is Dave's equivalent of a leaderboard — it surfaces him to the community as an expert. The recipe discovery system rewards the systematic experimentation mindset he naturally applies to systems. The XP cost scaling for multi-discipline investment prevents characters from maxing all disciplines trivially while still allowing breadth (Dave will try, and the system should let him feel the trade-off honestly rather than arbitrarily blocking him).
