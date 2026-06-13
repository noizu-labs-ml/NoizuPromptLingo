# US-241: Player Government Elections

**Persona:** Tyler — MMO refugee seeking growth, clans, and persistent impact
**Priority:** P2
**Epic:** Advanced Social & Governance

## Story
As Tyler, I want cities to have player-elected officials with real governance powers so that political competition becomes a meaningful endgame activity that rewards organized clans and long-term investment in a region.

## Acceptance Criteria
- [ ] Each major city supports three elected roles: Mayor (economic policy), Sheriff (law enforcement), Judge (dispute resolution), each with distinct command sets
- [ ] Election cycles run on configurable schedules (default: 30 real days); candidates register via accessible nomination interface with campaign statement field
- [ ] Voting is anonymous, one vote per eligible player per election; eligibility based on residency (time spent in city) thresholds configurable by admins
- [ ] Elected officials gain access to governance commands: Mayor sets tax rates (0–20%) on merchant transactions, Sheriff can issue warrants and assign bounties, Judge can commute sentences and mediate player disputes
- [ ] All election events (nomination open, voting open, results) announced via ARIA live regions and in-game mail to city residents
- [ ] Accessible candidate comparison view: navigate candidates by name, read platform statements sequentially, cast vote with confirmation dialog readable by screen readers
- [ ] Impeachment mechanic: citizens may petition (25% of eligible voters) to trigger recall vote; petition progress readable via status commands
- [ ] Election results narrated as civic announcement: winner name, vote totals, margin, and transition of power description broadcast to city channel

## Notes
Political systems in MMOs live or die on whether governance powers feel real. Tax controls must visibly affect merchant pricing so players notice the difference between a 5% and 15% tax. Sheriff warrant powers should integrate with the justice system (US-242) — a warrant issued by the Sheriff becomes prosecutable evidence in trials.

Accessibility is the hard part: a ranked-choice or multi-candidate ballot must be navigable without visual scanning. The solution is a sequential candidate list with arrow-key navigation, each candidate announcing name, clan affiliation, and a 140-character platform statement on focus. The vote confirmation should read: "You are voting for [Name] for [Office] in [City]. Press Enter to confirm, Escape to cancel."

Screen reader users who are running for office need the same campaign tools: a text field for their platform statement, a command to check their current vote tally (if they're a candidate), and notifications when votes are cast (aggregate only, not per-voter). Anti-griefing: candidates cannot see who voted for them, only totals at close of polls.

Consider allowing Clan leaders to endorse candidates, with endorsement visible on candidate profiles. This creates natural social pressure and political maneuvering without requiring visual UI.
