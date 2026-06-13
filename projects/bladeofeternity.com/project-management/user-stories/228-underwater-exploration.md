# US-228: Underwater Exploration

**Persona:** Jamie — IF enthusiast, sighted, narrative quality focused
**Priority:** P2
**Epic:** World Depth & Exploration

## Story
As Jamie, I want underwater zones to feel genuinely alien — with breath management, limited action sets, and evocative sensory narration — so that entering the water is a meaningful transition into a different kind of gameplay space.

## Acceptance Criteria
- [ ] Breath meter tracked in status channel while underwater: "Breath: 45s" counting down in real-time (or turn-based equivalent); warning at 30% and 10% remaining announced via live region
- [ ] Breath capacity modified by Constitution, Swimming skill, and equipment (diving helm extends breath, heavy armor reduces it significantly)
- [ ] Swimming skill checked for navigation; low-skill swimmers move slowly, get exhausted, risk currents; high-skill swimmers move fluidly with full action access
- [ ] Underwater action set reduced: melee weapons with swing mechanics (axes, two-handers) penalized; thrusting weapons (daggers, spears) unpenalized; ranged weapons unavailable; spells work with school-specific limitations
- [ ] Underwater sensory narration distinct from surface: sound travels oddly (describe muffled quality), vision limited by depth and clarity (described as murk or crystalline depending on water), pressure noted at depth
- [ ] Underwater rooms navigated in 3D: up, down, and lateral movement all available; vertical navigation described clearly: "You swim upward — the surface light grows brighter above you"
- [ ] Surfacing for air available when a surface is within range; if no surface accessible and breath runs out, drowning sequence begins with a final action opportunity to escape
- [ ] Underwater environmental features unique: air pockets allowing brief rests, strong currents requiring skill checks, bioluminescent creatures providing navigation context

## Notes
Jamie's interactive fiction sensibility means they want underwater to be a mode of experience, not just a reskinned dungeon. The breath countdown is the distinctive mechanical pressure of underwater — it creates urgency that's missing from standard dungeon exploration. The sensory narration vocabulary must be radically different from surface narration: underwater sound (distant, resonant, muffled), underwater vision (depth-dependent murk or clarity), underwater movement (resistance, weightlessness, current). The 3D navigation (including up/down) requires the position system (US-206) to handle vertical movement, which the physics engine already models — underwater is the most natural expression of this. The drowning sequence with a final action opportunity (grab the rope, break the surface, cast a water breathing spell) prevents instant death from feeling arbitrary. Air pockets as rest points reward exploration and create narrative safety valves. The reduced action set isn't punitive — it's realistic and creates interesting tactical constraints: Jamie will bring a dagger specifically for underwater content. The P2 priority reflects that this is a sophisticated system requiring the physics engine to handle buoyancy and 3D fluid navigation.
