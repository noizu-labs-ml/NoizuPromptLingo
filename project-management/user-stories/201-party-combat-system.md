# US-201: Party Combat System

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P0
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want to participate in coordinated group combat with other players against enemies so that I can experience the tactical depth of team-based PvP and PvE encounters without losing track of what's happening in the chaos.

## Acceptance Criteria
- [ ] Party of 2–6 players can engage a shared enemy group with a unified initiative order resolving via the OTP combat process
- [ ] Turn order announced at round start as a structured ARIA live region list: "Round 3. Turn order: Marcus (you), Elena, Tyler, Orc Warlord, Goblin Archer"
- [ ] Target selection UI navigable by keyboard with SR-friendly labeling including enemy health estimate and position relative to party
- [ ] Friendly fire rules enforced by physics engine: AoE attacks declare potential friendly targets before confirmation with a "Confirm friendly fire?" prompt
- [ ] Round summary narrated as a single coherent paragraph per combatant action, batched to avoid SR flooding: "Marcus strikes the Warlord for 34 damage. Elena heals Tyler for 22. The Warlord retaliates against Marcus…"
- [ ] Players can issue commands during other players' turns via a queue system; queued actions announced when submitted
- [ ] Party member status (HP, conditions) accessible via a dedicated status panel navigable outside of combat flow with H/P keyboard shortcuts
- [ ] Combat log persists and is searchable after combat ends, with round-by-round breakdown

## Notes
Party combat is the central social PvP/PvE activity and must be as legible to a screen reader user as to a sighted one. The key challenge is information density: 4–6 players plus multiple enemies can generate 20+ events per round. Batching into round summaries is non-negotiable. The OTP GenServer per combat must enforce strict sequencing — no race conditions where Marcus misses an event because his SR was mid-announcement. Live region politeness should be "polite" for status updates and "assertive" only for critical health thresholds (<20% HP) or sudden death. Friendly fire confirmation prevents catastrophic misclicks without being patronizing to experienced players. Party tab-order should follow initiative, not DOM order.
