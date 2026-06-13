# US-023: Combat Announcement Batching and Pacing

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Combat — Accessibility

## Story
As Marcus, I want combat round results delivered as a single cohesive narrative batch rather than a flood of individual ARIA updates so that my screen reader does not fragment or drop announcements during high-action exchanges.

## Acceptance Criteria
- [ ] All events within a single combat round are collected server-side and delivered as one prose block
- [ ] Prose block injected into a dedicated `role="log"` region with `aria-live="polite"` and `aria-atomic="true"`
- [ ] Round summary follows order: attacker action → defender reaction → damage/effect → status changes → round outcome
- [ ] Player-configurable verbosity: Full (all detail), Standard (key events), Brief (outcome only)
- [ ] Verbosity setting persisted to user profile and applied immediately without page reload
- [ ] "Replay last round" command re-injects previous batch without triggering a new round
- [ ] Multi-target AoE events aggregated: "You strike three opponents — Gareth (42 dmg), Mira (38 dmg), a shadow wraith (61 dmg)"
- [ ] No individual DOM mutations fire during batch assembly; single atomic update on batch completion

## Notes
The physics engine may generate 15–30 discrete events per round (collision, force, material response, status). These must be reduced to 3–5 prose sentences before delivery. The batch pipeline lives in the Phoenix backend; the frontend receives one WebSocket message per round. Consider a "slow mode" that introduces 800ms pauses between sentences for users who prefer sequential reading.
