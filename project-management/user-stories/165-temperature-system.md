# US-165: Temperature System

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Dave, I want rooms to have temperature states driven by fire, weather, season, and underground depth, with extreme temperatures affecting player physiology and narrated through physical sensation, so that environment is not merely decorative but imposes genuine mechanical consequence.

## Acceptance Criteria
- [ ] Each room maintains a `temperature` value in a defined range (e.g., -40 to 200 Celsius) computed from: base temperature (zone climate, depth), weather contribution (wind chill, solar radiation), active heat sources (fire intensity, magical sources), and passage-based thermal exchange with adjacent rooms
- [ ] Temperature updates on a simulation tick; extreme changes (entering a room with active fire) are immediate; gradual changes (outdoor temperature dropping overnight) occur over multiple ticks
- [ ] Temperature affects player stats at thresholds: comfortable range (no effect), cold (stamina drain), extreme cold (movement penalty, frostbite risk), hot (stamina drain, dehydration), extreme heat (burns, fire damage)
- [ ] Narration conveys temperature through physical sensation at each threshold: "Your breath fogs before you in the cold vault air" (cold); "Sweat runs freely down your neck — the air is barely breathable" (hot); "The skin on your face tightens against the freezing wind" (extreme cold)
- [ ] Players can mitigate temperature: fire and shelter against cold, water and shade against heat, appropriate clothing and equipment providing resistance buffs
- [ ] Thermal modeling considers convection: hot air rises (upper passages between floors carry warm air up), fire heats adjacent rooms through shared walls over time, cold seeps from underground rooms upward
- [ ] Temperature extremes create tactical environments: extreme cold slows enemies too; fire rooms are dangerous for all combatants; thermal differences between rooms can be exploited
- [ ] Temperature-sensitive materials behave appropriately: ice melts near fire, metals become too hot to handle near intense fire, certain alchemical substances react to temperature

## Notes
Dave will test the thermal physics against his intuitions as a technically literate sysadmin. He'll notice if underground rooms are warmer than outdoor winter rooms (geothermal gradient is correct — underground is warmer than the surface in winter), or if a small campfire heats a large stone hall to uncomfortable levels (it shouldn't — thermal mass of stone is enormous). The system should be physically plausible even if simplified.

The simulation tick for temperature should be longer than for fire propagation — thermal change is slow relative to fire spread. A fire started in a room makes the room hot within minutes; it takes much longer to warm adjacent rooms. This creates interesting tactical timing: you know the adjacent room will be uncomfortable in 10 minutes, giving you a window to act.

The narration vocabulary for temperature is rich and largely non-visual: sensation on skin, breath visibility, perspiration, muscle stiffness, the smell of hot stone, the taste of cold air. This makes temperature narration naturally accessible — there is no "see the temperature gauge." Temperature is communicated entirely through embodied experience, which is exactly the right approach for a text RPG.

Clothing and equipment as temperature mitigation creates a meaningful gear system dimension: a winter cloak is not just flavor, it's the difference between comfortable exploration and stat penalties. This connects the temperature system to the crafting and equipment systems — environmental conditions drive gear selection.
