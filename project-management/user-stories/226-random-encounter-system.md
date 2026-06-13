# US-226: Random Encounter System

**Persona:** Tyler — MMO refugee, sighted, growth/clans focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Tyler, I want random encounters during travel and wilderness exploration to be varied and region-appropriate so that moving through the world feels alive and dangerous, and the threat of unexpected combat keeps me engaged even on familiar routes.

## Acceptance Criteria
- [ ] Encounter probability varies by: region danger level, time of day, player level, group size, and current weather — all factors computed server-side per travel tick
- [ ] Encounter tables stratified by region (Forest Bandits distinct from Desert Raiders), time (day encounters vs night encounters with different enemy sets), and player level bracket
- [ ] Encounter types include: combat (most common), NPC interaction (merchant, traveler, herald), discovery (ruins, abandoned camp, shrine), environmental event (rockslide, flash flood), and rare events (named NPC encounter, world event trigger)
- [ ] Combat encounters signal approach before initiating: "You hear the clash of steel ahead — ambush or investigation?" giving players a choice
- [ ] Non-combat encounters fully navigable without SR interruption: NPC interaction follows standard dialogue pattern; discoveries add to exploration journal automatically
- [ ] Encounter frequency configurable within server-set bounds: Tyler can set "frequent encounters" for active play; reduced frequency available for casual transit
- [ ] Rare named encounters (1-in-500 chance) feature unique NPCs with their own lore and potentially world-persistent consequences: a bandit lord who remembers being spared
- [ ] Encounter history logged in exploration journal: region name, encounter type, outcome — Tyler can track his personal encounter record

## Notes
Tyler's MMO background means he's familiar with respawning enemy zones and wants the wilderness to feel similarly alive. The signal-before-combat approach ("you hear the clash of steel ahead") gives players agency: combat-ready Tyler charges in, cautious Elena can try to circumvent. Encounter frequency configuration is important for accessibility: players on mobile, players in short sessions, or players with cognitive fatigue should be able to reduce encounter frequency without eliminating it entirely. The server-set bounds prevent players from zeroing out encounters entirely and trivializing travel. Named rare encounters are the long-tail content that Tyler will discover by accident and tell his clan about: "I just met the Bandit King in the Thornwood — he remembered my character from six months ago." World-persistent NPC memory requires careful design (a Phoenix process per named NPC tracking interaction history) but creates the kind of emergent narrative that distinguishes this game. Encounter history log is Tyler's progression tracking: he wants to know how many bandits he's killed in the Thornwood.
