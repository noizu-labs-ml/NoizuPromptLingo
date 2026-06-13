# US-080: Community Events and Seasonal Content

**Persona:** Raj — Accessible Gaming Content Creator
**Priority:** P2
**Epic:** Community Events

## Story
As Raj, I want community events with announced schedules, accessible participation mechanics, and observable outcomes so that I can document and share event experiences in my content and showcase the game's social dimension to a broad audience.

## Acceptance Criteria
- [ ] Upcoming events are listed via `EVENTS` command with name, type, start time, duration, and participation requirements
- [ ] Event start is announced via a global Channel push to all logged-in players: "The Ironhaven Grand Market opens now. Bonus trade prices active for 2 hours. Type JOIN MARKET to participate."
- [ ] Event participation is a single command — no multi-step opt-in flow that creates accessibility barriers
- [ ] Event progress/leaderboards are accessible via `EVENT STATUS [name]`: text list of leaders with their scores
- [ ] Events accommodate solo and group participation; rewards scale with contribution, not just presence
- [ ] Post-event outcomes are archived and accessible: `EVENT HISTORY` lists past events with outcomes, winners, notable moments
- [ ] Event text descriptions are rich enough for screen reader users to understand theme and context without visual assets

## Notes
Raj streams and records his gameplay. Events must be compelling to watch and accessible to participate in. The announced start via Phoenix Channel is critical — blind players must receive the same real-time awareness as sighted players. Event descriptions should have the narrative quality Jamie would appreciate (US-076) — seasonal events especially should feel like world events, not game mechanics.
