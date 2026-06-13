# US-036: Kinetic Force and Knockback — Physics Consequence Narration

**Persona:** Jamie — Sighted IF enthusiast, literature grad student
**Priority:** P1
**Epic:** Physics — Kinetics

## Story
As Jamie, I want knockback, stagger, and forced movement to be narrated with physical honesty — momentum, weight, resistance — so that combat reads like embodied action fiction rather than a list of status effects.

## Acceptance Criteria
- [ ] Knockback narrated with direction, distance estimate, and surface interaction: "The blow lands square on your sternum and drives you back across the flagstones — five, six feet — until the wall stops you."
- [ ] Character mass affects narration: a heavier character staggers less, described as "you absorb the force, your weight an anchor"
- [ ] Opponent knockback narrated from player perspective: "Gareth stumbles back, catching himself against the column before he falls."
- [ ] Chain knockback (into another enemy or object) narrated as a sequence
- [ ] Stagger state explained in prose and game terms: "You are staggered — your next action costs additional stamina and Elusion is temporarily unavailable."
- [ ] Recovery narrated: "You find your footing — the moment of vulnerability passes."
- [ ] Knockback into environmental hazards (pits, fire, water) triggers environmental consequence narration
- [ ] Physics values (force in Newtons, distance in meters) never appear in player-facing narration — prose only

## Notes
Jamie will read every line of combat narration with a literature graduate's eye. Avoid passive voice for force events — "you are knocked back" is weaker than "the blow drives you back." The physics engine produces a knockback vector and distance; the prose pipeline must convert to directional prose ("back," "sideways," "off your feet") and distance impressions ("a step," "across the room"). Build direction-to-prose mapping for the eight compass directions plus up/down.
