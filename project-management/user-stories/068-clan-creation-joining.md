# US-068: Clan Creation and Joining

**Persona:** Tyler — Sighted MMO Refugee
**Priority:** P0
**Epic:** Clans

## Story
As Tyler, I want to create or join a clan with a full governance structure (ranks, permissions, charter) so that I can build a political organization with real teeth rather than a glorified friend list.

## Acceptance Criteria
- [ ] `CLAN CREATE [name]` initiates clan creation flow with prompts for: name, motto, charter (up to 500 chars), initial rank structure (default 5 tiers provided)
- [ ] Clan charter is a persistent text document readable by any player via `CLAN INFO [name]`
- [ ] Clan ranks have configurable permissions: recruit, invite, kick, declare war, manage treasury, manage territory
- [ ] `CLAN JOIN [name]` submits an application; clan officers receive a voiced/text notification via Phoenix Channel push
- [ ] Clan roster is accessible via `CLAN ROSTER` with each member announced: name, rank, online status, join date
- [ ] Clan creation costs a one-time fee (disclosed upfront) to prevent trivial proliferation
- [ ] Clan search (`CLAN SEARCH [keyword]`) returns results with name, member count, territory count, and recruitment status

## Notes
Tyler wants clan politics, not just grouping. The governance layer — permissions, charters, ranks — is the core of the feature. Screen reader output for roster and clan info must be clean list structures, not prose dumps. Phoenix Channels should push clan notifications in real-time.
