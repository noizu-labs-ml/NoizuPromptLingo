# US-078: Clan Diplomacy and Alliance System

**Persona:** Tyler — Sighted MMO Refugee
**Priority:** P1
**Epic:** Clan Politics

## Story
As Tyler, I want to form alliances, non-aggression pacts, and trade agreements with other clans so that inter-clan politics extends beyond binary war/peace into nuanced geopolitical maneuvering.

## Acceptance Criteria
- [ ] `CLAN DIPLOMACY` opens the diplomatic status board: listing all clans with current relation (ally, neutral, hostile, war)
- [ ] Diplomatic proposals are sent via `CLAN PROPOSE [clan] [pact-type]` (alliance, non-aggression, trade treaty)
- [ ] Proposed pacts include configurable terms: duration, mutual defense clause, resource sharing percentage, territorial boundaries
- [ ] Pact terms are displayed to the receiving clan's officers for approval vote via `CLAN VOTE [proposal-id]`
- [ ] Active pacts are announced when entering a clan's territory: "You enter land allied with your clan. Mutual defense active."
- [ ] Pact violations (attacking an ally) trigger an automatic diplomatic incident with escalation options
- [ ] Alliance network is traversable: `CLAN ALLIES [clan]` lists first and second-degree alliance connections

## Notes
Tyler wants a political simulation layer. The vote-based pact approval system creates internal clan politics too — officers with different foreign policy views. Screen reader output for diplomacy board must be a structured list, not a visual relationship web. Phoenix Channels should deliver pact proposals and votes in real-time to relevant officers.
