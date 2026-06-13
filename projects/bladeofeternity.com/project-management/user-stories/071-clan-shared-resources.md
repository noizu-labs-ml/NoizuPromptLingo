# US-071: Clan Shared Treasury and Resource Pool

**Persona:** Lena — Tabletop RPG Player, English Teacher
**Priority:** P1
**Epic:** Clans

## Story
As Lena, I want my clan to maintain a shared treasury and resource pool so that members can contribute to collective goals and withdraw what they need for group projects without informal trust arrangements.

## Acceptance Criteria
- [ ] `CLAN TREASURY` announces current gold, crystals, and material stockpiles with recent transaction summary
- [ ] `CLAN DEPOSIT [amount/item]` and `CLAN WITHDRAW [amount/item]` are gated by rank permissions
- [ ] All treasury transactions are logged with actor name, action, amount, and timestamp — accessible via `CLAN LEDGER`
- [ ] Clan officers can set per-member withdrawal limits and require officer approval above a threshold
- [ ] Treasury state is announced in full when accessed: no visual-only display of totals
- [ ] Contributions toward clan goals (territory upgrade, war chest) can be earmarked: `CONTRIBUTE 500 gold TO [goal]`
- [ ] Weekly treasury summary is delivered to all members via in-game mail

## Notes
Lena's tabletop instincts mean she'll want the treasury to feel like a shared party fund with accountability. The ledger is the accountability mechanism — make it thorough. Screen reader output: treasury should read like an accounting statement, not a tooltip. Transaction log should be navigable with timestamps.
