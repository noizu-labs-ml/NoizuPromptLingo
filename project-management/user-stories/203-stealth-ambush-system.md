# US-203: Stealth and Ambush System

**Persona:** Jamie — IF enthusiast, sighted, narrative quality focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Jamie, I want to stalk enemies through shadow, hold my breath at the edge of detection, and spring ambushes that feel like tense thriller moments so that stealth play delivers the same narrative satisfaction as combat.

## Acceptance Criteria
- [ ] Stealth mode toggled via S key; entering stealth announced: "You melt into the shadows, breathing shallow" with noise level and visibility status in status channel
- [ ] Detection uses contested roll: player Stealth skill vs enemy Perception, modified by light level, noise, terrain cover (physics-computed)
- [ ] Detection state communicated through environmental cues rather than meters: "A guard's lantern sweeps past — you press against cold stone. He doesn't see you." vs "Heavy footsteps falter — they've heard something."
- [ ] Near-detection events use ARIA live region with distinctive phrasing that conveys tension without explicit numbers: "Your heart hammers. Too close."
- [ ] Ambush trigger available when in stealth adjacent to unaware enemy; initiating combat from stealth grants Ambush Advantage: first strike cannot be dodged, +50% damage
- [ ] Ambush narrated as a burst description before initiative rolls: "You explode from darkness — your blade finds the gap in his armor before he can turn"
- [ ] Stealth broken by actions with noise levels above threshold; noise level of each ability visible in ability description
- [ ] Group stealth available for parties with all members in stealth; weakest member's stealth skill used for detection checks

## Notes
Jamie values narrative immersion above mechanics. The stealth system must resist the temptation to expose its internals (no "Stealth: 47 vs Perception: 32") and instead translate the math into prose. The physics engine provides cover and light calculations; the narration layer must convert these into sensory language — cold stone, held breath, the scrape of a boot. LLM narration should be triggered on near-detection events with a "tension spike" prompt modifier. Ambush advantage is the payoff for the tension investment; the narration should feel like a release. For blind players, the absence of visual detection cues (no health bar going orange, no enemy turning its head) means the prose cues are the only signal — they must be unambiguous about whether detection is imminent, active, or avoided. Group stealth encourages party coordination and should be mentioned in the tooltip.
