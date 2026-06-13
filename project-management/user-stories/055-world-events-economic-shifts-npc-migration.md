# US-055: World Events — Economic Shifts and NPC Migration

**Persona:** Tyler — Sighted MMO Refugee / Player Agency Seeker
**Priority:** P1
**Epic:** World Events & Emergence

## Story
As Tyler, I want the world to change in response to collective player actions and simulated economic forces so that the game world feels like a living system, not a static backdrop that resets every week.

## Acceptance Criteria
- [ ] An economic simulation runs server-side, tracking supply/demand for key commodity categories across Rune and Mordoon
- [ ] Economic shifts (scarcity, surplus, trade disruption) are announced as world events visible to all players in affected cities
- [ ] Economic shifts drive NPC behavior changes: merchants relocate, prices change, quest hooks emerge organically
- [ ] NPC migration events are announced as discoverable world news (not system notifications) — players learn through NPCs and rumor
- [ ] Player trade actions contribute to the economic simulation — bulk buying or selling moves markets
- [ ] `news` command aggregates current world events as in-world rumors and announcements
- [ ] World events persist for a configurable duration (minimum 3 real days) and resolve with visible consequences
- [ ] Economic state is queryable: `market <city>` shows current commodity pressure indicators in plain text

## Notes
- Tyler explicitly came from MMOs with static economies — meaningful market dynamics are a retention hook
- NPC migration must carry NPC memory/goal state (see US-047) — migrated NPCs remember the player
- World event announcements must reach blind players: `news` command is the primary channel, plus an ARIA live announcement when a major event fires
- Economic simulation need not be perfectly realistic — it should feel plausible and be responsive to player actions
- World events should feed quest generation (US-048): economic disruption creates NPC need, need creates quest hook
