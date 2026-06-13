# US-049: Acrylic Two-Phase Drying (Workable Then Locked)

**As a** mixed-media concept artist,
**I want to** experience a clear two-phase drying behavior in acrylic — an initial workable phase where paint blends, followed by a locked phase where it is permanently cured,
**So that** I can plan my workflow around the acrylic open-time window and know precisely when the paint is no longer workable.

## Personas
- **Primary:** P3 Lena Vasquez — understanding and exploiting the two-phase window is central to how she structures acrylic-based layering sessions
- **Also relevant:** P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Acrylic drying is represented as two discrete phases: Phase 1 (workable, evaporation-driven) and Phase 2 (cured, polymer cross-linking)
- [ ] During Phase 1, acrylic behaves similarly to a fast-drying water-based paint: blendable, liftable, and miscible with water
- [ ] Phase 2 onset is triggered when the moisture channel drops below a threshold; the paint then transitions to a locked, non-reworkable state
- [ ] The duration of Phase 1 is a configurable parameter affected by simulated humidity and retarder medium additives
- [ ] A subtle visual shift (slight matte change or edge crisping) signals the Phase 1-to-Phase 2 transition to the artist

## Notes
Two-phase drying maps to two drying-rate constants in the Drying stage: a fast evaporation constant for Phase 1 and an effectively-infinite cure time for Phase 2 (instantaneous lock on transition). Humidity as a simulation parameter is a future feature; for MVP, Phase 1 duration is a fixed per-media value.
