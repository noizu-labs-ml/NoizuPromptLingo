# US-235: Wilderness Survival Mechanics

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Dave, I want hunger, thirst, shelter, and rest to be resource management layers during extended wilderness expeditions so that preparation and self-sufficiency are skills that meaningfully extend what I can accomplish in the field.

## Acceptance Criteria
- [ ] Survival resources tracked: Hunger (degrades over real time), Thirst (degrades faster), Fatigue (degrades with physical activity), Shelter (relevant during cold/storm weather) — each with a named state: Well-Fed, Hungry, Famished, Starving
- [ ] Survival state communicated via physical condition narration rather than bars: Famished: "Your stomach cramps as you walk — it's been too long since you ate"; Exhausted: "Your limbs feel like lead; your reactions are slower than usual"
- [ ] Mechanical effects of survival states: Famished reduces stamina regeneration; Dehydrated reduces HP regen; Exhausted reduces combat accuracy and initiative; Hypothermic reduces all physical stats
- [ ] Campfire mechanics: player gathers wood (physics-based item collection in appropriate environments), lights fire (Survival skill check), cooks food, provides warmth and rest bonus; camp process narrated step by step
- [ ] Hunting as a food source: player tracks game (Survival + Perception check), makes a kill (ranged or trap), processes the carcass (butchering skill) to obtain food items; full sequence narrated
- [ ] Water sources found in wilderness (streams, wells, rain collection) for thirst management; contaminated water available in swamp zones requiring purification or risking illness
- [ ] Rest in camp restores Fatigue over game-time; party watch system available: one player watches while others rest, guard narrates any approach during watch
- [ ] Survival skill displayed in character sheet; increases through successful wilderness activities; higher skill reduces resource decay rates and improves foraging/hunting yields

## Notes
Dave will build a dedicated wilderness specialist character with maxed Survival skill. The resource management layer must be transparent enough that Dave can plan multi-day expeditions (how much food do I need for 3 game-days in the Thornwood?) without being onerous enough to make wilderness travel a burden. The physical condition narration over bars is the right design choice: "your stomach cramps" is both more immersive and more accessible (SR reads it naturally) than a hunger bar UI. The campfire mechanics as a multi-step process (gather, light, cook, rest) give Dave a satisfying activity loop during wilderness camping that rewards skill investment. Hunting as a full sequence (track, kill, butcher) adds a simulation layer that Dave will engage with obsessively. Contaminated water requiring purification is a knowledge-gate: Dave will research it and be appropriately cautious; Tyler might drink it and learn the hard way. The watch system for parties creates meaningful cooperation: do you split the watch evenly, or trust the character with the highest Perception? Party survival as a coordination challenge fits the game's social design.
