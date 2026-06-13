# US-070: Clan War Declaration and Resolution

**Persona:** Marcus — Blind Power Gamer
**Priority:** P1
**Epic:** Clans

## Story
As Marcus, I want to participate in declared clan wars with structured objectives and a win condition so that inter-clan PvP has strategic stakes beyond random kills.

## Acceptance Criteria
- [ ] `CLAN WAR DECLARE [target-clan]` initiates war with a required stated objective (territory capture, honor kill count, resource raid)
- [ ] War declaration triggers real-time Channel notification to all members of both clans
- [ ] War status is accessible via `WAR STATUS`: announcing current score, objectives, time remaining, and key recent events
- [ ] Kill events during wartime are announced to the war feed: "Marcus (Iron Covenant) has defeated Valdris (Ash Brotherhood). Kill count: 7/25"
- [ ] War resolution announces the winner with full stat summary and applies consequences (territory transfer, honor awards, tribute payment)
- [ ] War log is persistent and accessible post-conflict: `WAR HISTORY [war-id]`
- [ ] Neutral players in contested zones receive a warning on entry: "You are entering an active war zone between Iron Covenant and Ash Brotherhood."

## Notes
Marcus wants war to be a genuine competitive format. The kill-count / objective system must be unambiguous — no disputes about win conditions. Screen reader output for war status must be terse and navigable, not a paragraph. Phoenix Channels carry war feed events in real-time to all participants.
