# US-045: Travel Between Rune and Mordoon

**Persona:** Dave — Sighted MUD Veteran / Sysadmin
**Priority:** P1
**Epic:** World & Exploration

## Story
As Dave, I want inter-city travel to feel dangerous and consequential — with route choices, travel time, and encounter potential — so that the journey between Rune and Mordoon matters as much as the destinations.

## Acceptance Criteria
- [ ] At least two distinct routes exist between Rune and Mordoon (e.g., the King's Road, the Deadmarch)
- [ ] Each route has different travel time, danger level, and encounter table
- [ ] `travel <destination> via <route>` initiates travel with a summary of expected time and risk
- [ ] Travel generates 1–3 narrative vignettes en route (AI-generated, route-specific)
- [ ] Encounters during travel are optional interruptions: player receives a prompt and can engage or attempt to evade
- [ ] Travel state is persistent — player can be disconnected mid-travel and resume on reconnect
- [ ] `travel status` reports current progress, remaining time, next encounter window
- [ ] Arriving at destination triggers a short arrival description distinct from the standing room description

## Notes
- Dave values systemic depth; travel should plug into the world event system (e.g., bandits more common during economic unrest)
- Travel vignettes are seeded with route + weather + world state to ensure variety
- Disconnection persistence is critical — sysadmin will notice if reconnect drops travel state
- Both routes should appear in lore; the King's Road is safe and official, the Deadmarch is faster but skirts necromantic territory
- Future routes (sea passage, underground tunnel) should be accommodated by the travel API design
