# US-156: Environmental Hazard Narration

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P0
**Epic:** Mutable World & Environment

## Story
As Marcus, I want every environmental hazard — fire, toxic gas, unstable floors, rising water, electrical discharge — to be announced through appropriate ARIA channels with sufficient urgency, directionality, and clarity that I perceive danger at exactly the same moment and with the same fidelity as sighted players, with clear escape direction narration when my life is at risk.

## Acceptance Criteria
- [ ] A HazardAlert system classifies hazards by severity: `informational` (ARIA polite, awareness only), `warning` (ARIA polite, action recommended), `critical` (ARIA assertive, immediate action required), `lethal` (ARIA assertive, interrupt all other narration)
- [ ] Critical and lethal hazard announcements include directional escape information when at least one safe exit exists: "Lethal. Ceiling collapse imminent. The eastern archway remains clear."
- [ ] Hazard announcements include sensory cues appropriate to the hazard: fire narration mentions heat and smell; gas narration mentions acrid taste and burning eyes; unstable floor narration mentions vibration and cracking sounds beneath feet
- [ ] Hazard narration uses progressive escalation: hazard onset (informational) → worsening (warning) → dangerous threshold (critical) → lethal (assertive interrupt) — players have time to react at each stage
- [ ] When no safe escape exists, ARIA assertive announces this explicitly: "All exits are compromised. The room is filling with smoke." — no false hope, but also no leaving players to guess
- [ ] Hazard detection does not require special commands — the system passively monitors and announces; players do not need to poll for danger
- [ ] NVDA+Firefox ARIA live region behavior is specifically tested: assertive regions interrupt speech immediately; polite regions queue without cutting narration
- [ ] Hazard states are accessible via explicit query ("examine surroundings" or "check hazards") returning a structured list of current hazards and their severity for players who want the full tactical picture

## Notes
This is Marcus's P0 requirement because environmental awareness is where text RPGs historically fail blind players most severely. In visual games, hazard warnings are communicated through color, animation, and spatial audio — modalities unavailable to screen reader users. Every design decision here must ask: "Does this reach a blind player with the same urgency as a sighted player sees a flashing red warning?"

The ARIA channel architecture is critical: use `aria-live="polite"` for informational and warning-level hazards to avoid interrupting ongoing narration; use `aria-live="assertive"` only for critical and lethal hazards. Never use assertive for non-urgent information — overuse of assertive destroys the signal-to-noise ratio that makes it valuable.

Directionality in hazard narration requires the room GenServer to maintain a directional model. When announcing "fire spreading from the north," the system must know which exits are north-of, south-of, east-of, west-of the hazard origin. This connects to the room's spatial model — exits should always be described in cardinal or relative terms that are consistent across the session.

Test with Marcus's actual setup: NVDA+Firefox. Common failure modes: assertive live regions that are throttled by Firefox and arrive late; polite regions that are ignored because the speech queue is already full; live region updates that NVDA reads as "blank" due to DOM manipulation timing. These are real accessibility bugs with real solutions — test them.

Marcus's power-gamer profile means he will use hazard information tactically: retreat when a corridor floods, press advantage when an enemy is caught in fire, exploit gas clouds. The hazard narration must be precise enough to support this level of tactical reasoning.
