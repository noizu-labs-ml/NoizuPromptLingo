# US-172: Underground Environment

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P1
**Epic:** Mutable World & Environment

## Story
As Marcus, I want underground environments — caves, mines, sewers, crypts — to have distinct physics and narration modes that leverage sound echo, mineral smell, water presence, and darkness as primary sensory channels, giving me a genuine environmental advantage as a screen reader user in domains where non-visual perception is king.

## Acceptance Criteria
- [ ] Underground room types carry acoustic modifier `echo_coefficient: 0.0..1.0`; high-echo rooms (large caverns, stone corridors) amplify sound and extend propagation range; low-echo rooms (dirt tunnels, cloth-hung chambers) muffle sound
- [ ] Darkness is the default state underground; players must carry or discover light sources; room descriptions default to non-visual narration when unlit: sound, smell, touch, spatial sense conveyed through echo
- [ ] Cave-in hazards are physics-driven: structural integrity (US-154) applies to tunnel ceilings; mining activity, combat, and explosions reduce ceiling integrity; cave-ins produce blocked passages, debris, dust, and sound heard across multiple adjacent rooms
- [ ] Underground water features (springs, flooded tunnels, underground rivers) interact with the water physics system (US-155); underground flooding can be sudden and catastrophic
- [ ] Mineral deposits are detectable through narration before visual confirmation: "The rock here has a metallic taste to it when the damp air touches your lips — iron ore, maybe, or something richer" — appropriate skills reveal specific type and quantity
- [ ] Echo-based spatial awareness: in high-echo rooms, the AI narrator can convey room size, ceiling height, and rough shape through sound description: "Your footstep sends sound racing across a void — the echo returns from far above and far ahead. This cavern is vast."
- [ ] Underground temperature gradient (geothermal): depth affects base temperature; deep caves are warmer than the surface in winter; volcanic regions significantly warmer; this affects equipment and creature behavior
- [ ] Sewer environments include distinct narration elements: water flow direction (audible), rat presence, settlement above (sounds filtering down), waste disposal from above (periodic additions to the water), maintenance access points to surface

## Notes
Underground environments are where Marcus's screen reader experience becomes a genuine gameplay advantage. The echo-based spatial perception mechanic is designed specifically for this: a player who already processes the world through sound and spatial narration will find underground acoustics intuitive and information-rich, while sighted players accustomed to visual spatial cues may find it disorienting.

The echo-based room size narration is a specific design decision worth protecting: it's not just flavor, it's a functional accessibility feature that conveys spatial information through an auditory modality. The implementation should ensure that room size/shape information is always available through this mechanic so that Marcus is never navigating blind (in the gameplay sense) through a space he cannot mentally map.

Cave-in dynamics should be tense and dramatic without being unfair. Progressive warning narration (ceiling creaking, dust, small rockfalls) must precede catastrophic failure. The collapse event itself should be immediate and assertive — but the player should have had several seconds of warning to make a decision. The aftermath (blocked passage, debris field, potential rescue if other players are nearby) should be narratively rich.

Sewer environments deserve specific attention because they connect to urban gameplay in interesting ways: a skilled sewer navigator knows routes under the entire city, can surface in unexpected locations, overhear conversations from grates above, and access restricted areas. The sewer is a social and strategic layer beneath the city's social geography.
