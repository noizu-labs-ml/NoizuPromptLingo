# US-157: Player-Built Barricades

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Tyler, I want to construct barricades from available room materials — overturned furniture, stacked crates, debris, harvested timber — so that I can control chokepoints, protect clan territory, and create defensive positions that degrade realistically under attack.

## Acceptance Criteria
- [ ] Players can construct barricades using `barricade [direction] with [material]` syntax, consuming available materials from room inventory; command auto-suggests available materials
- [ ] Barricade stats are computed from material properties: wood furniture provides light cover (30% damage reduction, 50 integrity); stone rubble provides heavy cover (60% damage reduction, 200 integrity); iron scraps provide reinforced cover (75% damage reduction, 400 integrity)
- [ ] Barricade state is tracked in room GenServer as part of passage state: `%PassageState{direction: atom, barricade: %Barricade{material, integrity, cover_rating, constructed_by, constructed_at}}`
- [ ] Barricades degrade under attack (each hit reduces integrity) and over time (configurable decay rate per material, default: wood degrades in 24h, stone in 72h, iron in 168h)
- [ ] The physics engine calculates cover effectiveness in combat: attacking from behind a barricade grants defensive bonus; attacking through a barricade reduces incoming projectile damage proportional to cover_rating
- [ ] Barricades block NPC pathfinding until destroyed; guards will attempt to break down barricades blocking their patrol routes after a delay
- [ ] Room description updates to reflect barricade presence: "A rough barricade of overturned tables and splintered shelving blocks the western doorway"
- [ ] Clan-constructed barricades display clan affiliation and can be reinforced by clan members using additional materials

## Notes
Tyler's MMO background means he thinks in terms of territory control and clan warfare. Barricades are a fundamental defensive tool — the ability to fortify a chokepoint and hold it is central to clan vs. clan gameplay. The system must support the full lifecycle: rapid construction under pressure, reinforcement during downtime, degradation under sustained attack, and eventual destruction.

The material sourcing mechanic creates interesting decisions: do you destroy the room's furniture (depriving yourself of other uses) to build a barricade? Do you carry construction materials? The barricade system should integrate naturally with the broader object interaction system — anything large and heavy in a room is a potential barricade component.

Physics-based cover calculation should be accessible in narration. "The iron-reinforced barricade takes the brunt of the crossbow bolt, sending a shower of sparks across the doorframe" communicates both the defensive function and the material properties without requiring the player to consult a stat sheet. Marcus, playing alongside Tyler, needs the same tactical information — cover quality should be inferable from description alone.

Decay is important for world hygiene: abandoned barricades should not permanently alter the world topology. The decay system should accelerate when a room has no active players for an extended period (zone cleanup mechanic), and barricade remains (partially decayed) should be narratively interesting: "The remnants of an old barricade — rotted wood and scattered nails — have mostly collapsed against the doorframe."
