# US-202: Boss Encounter Mechanics

**Persona:** Tyler — MMO refugee, sighted, growth/clans focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Tyler, I want boss fights to have multiple distinct phases with unique mechanics and clearly communicated vulnerability windows so that my clan can coordinate strategy and feel genuine triumph when we overcome a challenging encounter.

## Acceptance Criteria
- [ ] Boss encounters have 2–5 distinct phases triggered by HP thresholds (e.g., 75%, 50%, 25%) with unique move sets per phase
- [ ] Phase transitions announced immediately via assertive ARIA live region: "PHASE TRANSITION — The Lich King shatters his phylactery. His defenses are shattered but his power doubles." with a 2-second pause before combat resumes
- [ ] Special attacks telegraphed one tick before execution: "The Dragon inhales deeply — a fire breath is imminent" allowing counter-actions
- [ ] Vulnerability windows (e.g., stunned, exposed flank) announced with duration: "The Golem's core is exposed — 2 rounds to exploit it"
- [ ] Phase indicator accessible as a landmark region showing current phase name, HP band, and active special mechanics
- [ ] Boss abilities listed in an accessible reference panel (toggled with B key) without interrupting combat flow
- [ ] Death/victory narrated as a climactic set-piece: multi-sentence description of the boss's defeat fitting its lore
- [ ] Post-encounter loot and achievement unlocks announced in structured summary distinct from standard post-combat output

## Notes
Boss encounters are Tyler's primary motivation for building a clan — they're the content that requires coordination and generates shared stories. Phase transitions must feel dramatic, not clinical. The LLM narration layer should generate boss-specific flavor text for each phase transition; the system should pass boss ID and phase number to the LLM prompt template registry (US-107) so transitions feel unique per boss. Vulnerability windows are the tactical core — the physics engine should compute them based on animation state (stun, knockdown, exposed) and the combat system must surface them immediately. Blind players need identical vulnerability information as sighted players — this is a P0 accessibility requirement embedded in a P1 story. Boss reference panel should list phase names so Tyler can brief his clan beforehand using observed data from prior attempts.
