# US-159: Environmental Traps

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Dave, I want to set pit traps, tripwires, pressure plates, and alarm mechanisms that interact with the physics engine and NPC pathfinding, so that dungeon defense and tactical gameplay involve genuine environmental engineering rather than just combat stats.

## Acceptance Criteria
- [ ] Trap construction requires: appropriate materials (wire, pit stakes, trigger mechanisms), relevant skill level (Trapping/Engineering), and unobserved setup time — traps cannot be set while observed by hostile NPCs or enemies
- [ ] Trap state is stored per room: `%TrapState{type: atom, location: position, trigger: %TriggerSpec{}, effect: %EffectSpec{}, concealment: 0..100, set_by: player_id}`
- [ ] Detection is based on Perception skill vs. Concealment value: high-Perception characters and NPCs receive a "you notice something odd" hint in room description without revealing trap specifics; low-Perception characters receive no hint
- [ ] Triggered traps produce appropriate physics effects: pit traps open a floor section (modifying room spatial model); tripwires trigger attached effects (alarm, dart, fall); pressure plates activate mechanical consequences
- [ ] Trap triggers generate accessible ARIA announcements: "A wire catches your ankle. Before you can react, the floor gives way." — sensory and immediate, delivered as assertive ARIA
- [ ] Players can attempt to disarm detected traps via `disarm trap [location]` — success based on skill, failure may trigger the trap or damage the disarming attempt
- [ ] Traps interact with NPC pathfinding: NPCs with Perception > trap Concealment avoid the trap's location; NPCs without sufficient Perception may trigger traps during patrol
- [ ] Trap durability: single-use traps (pits) are consumed on trigger; reset-capable traps (alarms, pressure plates) can be re-armed; all traps degrade over time without maintenance

## Notes
Dave's systems-thinking orientation means he'll architect elaborate trap networks: a tripwire triggering an alarm, the alarm attracting guards, the guards funneled through a pit trap, the pit trap triggering a secondary alarm. The system must support trap chaining: one trap's effect can serve as another trap's trigger.

The concealment system needs careful tuning. A master trapper should be able to lay traps that only the most perceptive opponents detect; a novice's traps should be relatively obvious. This affects not just NPC pathfinding but player-vs-player gameplay — stealth characters scouting ahead should be able to detect traps before the main group triggers them.

Physics interactions are key: a pit trap doesn't just "damage the player" — it opens a hole in the floor that persists as a room modification. Fallen characters are now in a pit (lower elevation zone) and must climb out. The pit affects subsequent movement in the room. The dart from a dart trap is a physical projectile that follows ballistic physics and may miss if the target dodges.

For accessibility, the trap trigger narrative must convey both the sensory experience and the mechanical consequence in a single, immediate description. Players should never be confused about what happened to them. "A thin wire — you never saw it — snaps taut across your shin. The floorboards hinge downward. You drop six feet into cold earth and darkness, landing hard." This is complete information: sensory experience, cause, location consequence.
