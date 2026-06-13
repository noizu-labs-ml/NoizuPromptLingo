# US-229: Portal and Teleportation Network

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P1
**Epic:** World Depth & Exploration

## Story
As Dave, I want a magical portal network connecting distant parts of the world so that the geography has shortcuts requiring effort to unlock, and portal activation is a system I can understand, map, and exploit for efficient travel.

## Acceptance Criteria
- [ ] Portal nodes placed at significant world locations; each portal has a visible physical description and an "examine" interaction revealing its activation requirements
- [ ] Activation requirements vary by portal: specific key item, spell cast at the portal, time-of-day condition, knowledge of a runic sequence, or completing a linked quest
- [ ] Activated portals registered in world map (US-224) as a "Portal" type location with activation status; connected destination listed once known
- [ ] Portal activation sequence narrated with appropriate mystical weight: "You press the matching runestones in sequence — the archway blazes with cold blue light, the air shimmers, and you feel the pull of distant space"
- [ ] Arrival disorientation: entering a portal delivers a brief disorientation narration before the destination room description: "Your vision whites out — for a moment you are nowhere — then the world snaps back into focus"
- [ ] Bidirectional portal pairs: activating one end registers both directions in the world map; some portals one-way only (noted in description)
- [ ] Portal network map view accessible from world map with filter: shows only portal nodes and their connections as a network list: "Ironhold Gate → Sunken Ruins (active) | Eastern Spire (locked — requires Runic Key)"
- [ ] Portal failures narrated: incomplete activation sequence, missing item, or wrong time triggers a failure description that hints at what was wrong without explicitly stating the missing element

## Notes
Dave wants to understand how systems work and then exploit them. Portal networks are a systems-legible feature: once Dave knows the activation rules, he can plan routes, acquire keys, and build efficient travel infrastructure for his gameplay. The activation requirements diversity (keys, spells, time, quests) means different player types encounter different portal discovery moments. Portal failure narration that hints without stating ("The runestones flare momentarily, then dim — something is out of sequence") respects Dave's puzzle-solving orientation: he'll figure it out. The disorientation arrival narration is the fiction-layer that makes teleportation feel like transportation rather than a database record change — Jamie will appreciate it too, but Dave will accept it as long as it's brief and consistent. The portal network list view from the world map is a Dave-specific need: he wants the topology, not just individual locations. One-way portals add asymmetric geography that creates interesting route planning: you can portal from A to B but not back, so you need to plan your return route. Portal activation state persistence means server-side portal state must be stored per player account.
