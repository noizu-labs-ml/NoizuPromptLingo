# US-158: Terrain Modification

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Tyler, I want to dig, fill, build steps, and otherwise reshape the physical terrain of rooms and passages so that my clan can engineer strategic advantages — defensive ditches, elevated firing positions, shortcuts between areas — that persist and affect combat dynamics.

## Acceptance Criteria
- [ ] Terrain modification commands (`dig [direction] [depth]`, `fill [area] with [material]`, `build steps [direction]`) are gated by: appropriate tools in inventory, terrain type (soft earth is diggable; bedrock is not), and sufficient time/effort
- [ ] Terrain changes are represented in the room's physical model: floor elevation map updates, passage elevation differentials are recalculated, movement speed modifiers are applied based on terrain type and slope
- [ ] Dug trenches and ditches reduce movement speed for traversers; elevated positions grant ranged attack bonus and impose melee penalty on attackers charging uphill — physics engine computes these modifiers
- [ ] New passages created by digging (break through a wall, dig under a door) register in the room graph and become traversable once complete; passage width affects what can move through
- [ ] Terrain modifications persist in room GenServer state and are included in room version history (US-160) for full audit trail
- [ ] AI narrator describes terrain modifications in spatial terms: "A trench cuts across the northern approach, three feet deep, its walls reinforced with rough timber planks"
- [ ] Filling operations reverse previous excavations or raise floor level; over-filled areas create raised platforms affecting line-of-sight and elevation advantage
- [ ] Large-scale terrain modification (digging a new room, collapsing a tunnel) requires coordinated effort from multiple players or significant time investment, preventing trivial world reshaping

## Notes
Tyler is thinking about territory control at scale: clan compounds with engineered defenses, moats, elevated walls, covered approaches. This is essentially the text-RPG equivalent of StarCraft base-building. The terrain system must support this ambition while maintaining world coherence — you can't dig through bedrock or build a second story without structural support.

The physics engine's spatial model needs to support elevation maps per room, not just a single elevation value. A room with a trench across it has three elevation zones: the trench bottom, the original floor, and potentially a raised platform. The movement system must handle transitions between these zones (climbing into/out of trenches, stepping up to a platform).

Tool requirements add tactical depth: digging requires a shovel or pick; building steps requires timber and tools; filling requires available fill material. This creates supply chain considerations — clans that control access to digging tools can monopolize terrain modification in contested areas.

For accessibility, terrain changes must be thoroughly described in room narratives. A sighted player can see a trench visually; Marcus using NVDA needs the same spatial awareness from prose. The room description should always convey current terrain geometry: "The room floor drops away sharply at the northern wall — a trench, roughly three feet wide and four feet deep, cuts across the approach to the iron gate." This is both good writing and a WCAG requirement.
