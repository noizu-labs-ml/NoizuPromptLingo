# US-167: Vegetation Growth & Decay

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P2
**Epic:** Mutable World & Environment

## Story
As Lena, I want plants to grow, spread, die, and be harvested across seasons, with overgrowth gradually reclaiming neglected spaces and fire clearing ground for new growth, so that the world has a biological rhythm that rewards attentive observation over multiple sessions.

## Acceptance Criteria
- [ ] Outdoor and semi-outdoor rooms carry vegetation state: `%VegetationState{coverage: 0..100, type: [plant_type], harvestable_materials: [%HarvestableItem{type, quantity, season_available}], growth_rate: float}`
- [ ] Vegetation grows over time (configurable tick rate), spreading from high-coverage rooms to adjacent low-coverage rooms if passage and climate conditions are suitable; growth rate varies by season
- [ ] Overgrowth mechanically affects rooms at thresholds: coverage > 60% slows movement ("you push through thick undergrowth"); coverage > 85% restricts some passages ("vines and brush have reclaimed the eastern path entirely — you would need to cut through")
- [ ] Harvestable materials vary by season: spring yields shoots and early herbs; summer yields full-growth herbs, berries, and building materials; autumn yields seeds, dried herbs, and mature timber; winter yields bark, roots, and minimal yield
- [ ] Fire clears vegetation completely and immediately, leaving ash-enriched soil with an accelerated regrowth rate afterward; players who burn then wait gain faster-growing cleared areas
- [ ] Herbalists and gatherers with appropriate skills can identify harvestable materials before gathering: "Examine vegetation" yields a detailed listing of what's present and when it can be harvested
- [ ] AI describes seasonal flora changes with editorial care: spring vegetation gets tender, hopeful prose; autumn decay is elegiac and specific ("the fern fronds have gone the deep brown of old leather")
- [ ] Neglected urban spaces (abandoned buildings, untended courtyards) show progressive vegetation reclamation over weeks of in-game time — a vivid indicator of world history

## Notes
Lena's tabletop RPG sensibility means she reads vegetation as worldbuilding signal. An overgrown courtyard tells a story without exposition — something happened here, people left, nature returned. The vegetation system should function as environmental storytelling (connecting to US-174): the state of plants in a room conveys its history and current occupancy.

The harvestable material system connects vegetation to crafting and commerce. Herbalists will develop routes through the world, returning periodically to harvest specific plants at their seasonal peak. This creates a natural rhythm for short-session players like Lena: a 45-minute session can be "my gathering circuit this week," with the world rewarding regular return.

Fire-clear-and-regrow is ecologically accurate (fire is a natural growth cycle mechanism) and creates an interesting player choice: burn an overgrown area to clear passages and accelerate future growth, accepting short-term obstacle clearance at the cost of destroying current harvestable materials. This trade-off gives vegetation an interesting strategic dimension beyond mere aesthetics.

The prose quality for vegetation narration should be among the system's best — vegetation description is a core literary tool. "The garden is overgrown but not abandoned — someone has trained the climbing roses along the southern wall with recent care, though the beds between are a season's worth of neglect" communicates simultaneously the physical state, implied history, and current occupation status.
