# US-173: Magical Environment Effects

**Persona:** Jamie — IF enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Jamie, I want enchanted areas to exhibit unusual physical behavior — reversed gravity, time distortion, spatial folding, manifested emotions, unstable reality — narrated through disorienting but navigable prose that conveys genuine strangeness without becoming inaccessible or mechanically arbitrary.

## Acceptance Criteria
- [ ] Magical environment types are implemented as physics modifier overlays: `%MagicalModifier{type: atom, intensity: 0..100, affected_properties: [atom], description_override: string}` applied to room's physics calculations
- [ ] Supported magical environment types at launch include: gravity alteration (movement directions change, objects behave unexpectedly), time distortion (tick rate appears different from inside, effects persist longer or shorter), spatial warping (distance between rooms distorted, passages non-Euclidean), emotional emanation (NPCs and players receive mood effects)
- [ ] Narration conveys magical disorientation through embodied sensation and cognitive experience, not visual description alone: "Your feet lift from the floor with each step rather than pressing into it — movement requires a constant act of will against the wrongness of the place"
- [ ] Magical environments affect gameplay abilities in zone-appropriate ways: gravity alteration changes projectile trajectories; time distortion affects effect durations; spatial warping may alter which rooms are adjacent; magic-resistant characters are less affected
- [ ] Entry into a magical area is narrated with calibrated strangeness — the transition itself is an experience: "The moment you cross the threshold, your stomach drops as though you stepped off a ledge. The air has a pressure to it, like sound just below the range of hearing."
- [ ] Players can use skills and items to understand and navigate magical environments: "Attune to area" reveals the nature of the magical effect; appropriate items may provide resistance or exploitation tools
- [ ] Magical environmental effects are lore-grounded: each type of magical environment has an in-world explanation (ancient spell site, presence of a magical entity, ley line intersection) accessible through examination and lore skills
- [ ] Accessibility of magical environments is explicitly tested: all disorientation must be expressed through narration accessible to screen reader users; confusion must never manifest as UI breakage or navigation failure

## Notes
Jamie's interest in narrative quality means magical environments must be genuinely strange and carefully written — not merely "combat zone with visual effects" but places with their own experiential logic. The best magical environment narration makes the strangeness coherent: once you understand that gravity here pulls toward a point rather than a direction, the implications cascade naturally.

The non-Euclidean spatial warping mechanic is particularly interesting for a text RPG: in a visual game, non-Euclidean space is difficult to render convincingly; in a text game, it's trivially implementable (a passage "north" connects to a room that is logically south; walking in a circle brings you somewhere new) and can be narrated with appropriate disorientation. "You've walked north for what feels like ten minutes. The room you step into is familiar — but you've never approached it from this direction before."

The accessibility requirement for magical environments is non-negotiable: magical confusion must never cause ARIA live region failures, broken navigation, or incomprehensible narration. The confusion is narrative, not technical. A screen reader user experiencing a gravity-reversal zone must receive a clear, coherent (if disorienting) description of what has changed, how to navigate it, and what has remained constant. Confusion-as-inaccessibility is a bug, not a design choice.

Lore grounding is important for Jamie's literary sensibility: magical environments that exist as pure mechanical modifiers feel video-game-cheap. Magical environments should have histories, reasons, and implications — the gravity-warped chamber is the former workspace of a mage who specialized in spatial manipulation and whose experiments left permanent impressions on reality. This transforms the mechanical quirk into worldbuilding.
