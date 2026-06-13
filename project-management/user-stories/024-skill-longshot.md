# US-024: Longshot Skill — Ranged Combat with Spatial Narration

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Combat — Skills

## Story
As Marcus, I want the Longshot skill to communicate range, trajectory, and environmental interference through prose so that I can make informed ranged attack decisions without visual spatial cues.

## Acceptance Criteria
- [ ] Longshot skill available in combat action menu under "Skills" group
- [ ] Before execution: system narrates estimated range band (close/medium/long/extreme), line-of-sight status, and any environmental penalties (wind, cover, elevation)
- [ ] Execution narration describes arc, travel time impression, and point of impact: "The bolt climbs in a tight arc, crosses thirty yards of open courtyard, and buries itself in the gap between Gareth's pauldron and gorget."
- [ ] Hit/miss/graze outcomes each have distinct prose patterns distinguishable without visual indicator
- [ ] Critical hit narration is qualitatively richer, not just a damage number increase
- [ ] Physics modifiers (wind speed, rain, darkness) verbally flagged before skill activation if they degrade accuracy by >15%
- [ ] Skill cooldown announced as prose duration ("available in two rounds") not just a number
- [ ] Longshot unlocks upgraded narration depth at skill rank 3 and rank 5

## Notes
The physics engine calculates actual projectile arcs. The prose pipeline must translate ballistic simulation output (angle, velocity, drag, collision normal) into evocative range language. Build a narration template library keyed to range band × hit location × armor type combinations to avoid repetitive phrasing.
