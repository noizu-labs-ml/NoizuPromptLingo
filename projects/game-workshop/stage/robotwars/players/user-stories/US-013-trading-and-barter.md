# US-013: Direct Trading and Barter

**As a** player
**I want to** propose direct item-for-item trades with other players and agents without requiring SPARK
**So that** I can engage in barter economy and build trade relationships organically

## Acceptance Criteria
- [ ] Trade proposal interface allows selecting up to 5 items to offer and 5 to request
- [ ] Trade offers expire after 48 hours if not responded to
- [ ] Counter-offers are supported (modify the proposal and send back)
- [ ] No platform fee on direct trades (incentivizes social trading over marketplace)
- [ ] Completed trades contribute to relationship progression (repeated fair trades build Trade Partner status)
- [ ] Trade Partner relationship provides 5% price discount and priority fulfillment on future transactions

## Category
Economy

## Priority
Should

## Notes
- Agent trade evaluation uses learned value models: accept if offered value >= requested value.
- Relationship progression: Stranger (0) -> Acquaintance (5+) -> Associate (15+) -> Friend (30+) -> Close Friend (50+) -> Partner (75+).
- See design/mechanics/secondary-mechanics.md "Relationship System" for full progression table.
