# US-077: Player Reputation System

**Persona:** Raj — Accessible Gaming Content Creator
**Priority:** P1
**Epic:** Social Systems

## Story
As Raj, I want a player reputation system that tracks trustworthiness, crafting excellence, and community contributions so that I can surface and spotlight players who make the game better for everyone.

## Acceptance Criteria
- [ ] Player profiles display a Reputation Score with component breakdown: trader reliability, crafting reputation, community standing, combat honor
- [ ] Reputation is earned through verifiable actions: completed trades, crafted masterwork items, forum post endorsements, helping new players
- [ ] Players can endorse others via `ENDORSE [player] [category]` (one per category per week per endorser)
- [ ] `REPUTATION [player]` announces the full breakdown and recent reputation events: "Arkhan — Trader: Excellent (47 completed trades, 0 disputes). Crafter: Master (12 masterwork attributions)."
- [ ] Negative reputation events are recorded: failed trades, reported harassment, criminal convictions
- [ ] Reputation is visible on player inspect and in trade windows
- [ ] Screen reader output for reputation summary uses a definition list (`<dl>`) structure: category/value pairs

## Notes
Raj creates content showcasing accessible games. A rich, transparent reputation system gives him material to highlight — players with high reputation become community figures worth featuring. The system must be resistant to gaming (vote rings) — endorsement limits and category specificity help. Reputation should be a social signal, not a gate.
