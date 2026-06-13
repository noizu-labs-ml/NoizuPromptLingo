# US-197: Buff & Debuff Tracking

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Marcus, I want active buffs and debuffs displayed in a status panel with duration timers and expiration announcements through the status ARIA channel so that I can manage my combat state precisely without missing critical status changes.

## Acceptance Criteria
- [ ] Status panel displays all active buffs and debuffs as separate SR-navigable lists: buffs (positive effects) listed first, debuffs (negative effects) listed second; accessible via keyboard shortcut at all times
- [ ] Each buff/debuff entry reads on focus: effect name, source (ability name or caster name for PvP), remaining duration in seconds, and effect description ("Increases Strength by 20% — from Battle Cry — 45 seconds remaining")
- [ ] Debuff expiration announced via polite status ARIA channel: "Poison fades." Buff expiration announced similarly: "Battle Cry expires."
- [ ] Critical debuff application (stun, root, silence, heavy bleed) triggers assertive ARIA interrupt: "You are stunned! Unable to act for 3 seconds."
- [ ] Duration timers update server-side; client renders remaining time without requiring polling; expired effects automatically removed from panel with immediate UI update
- [ ] Buff application from external source (healer casting on player) announced via polite ARIA: "Elena's Blessing of Fortitude: your HP regeneration increased. 2 minutes remaining."
- [ ] Status panel shows maximum of 20 simultaneous effects; if limit reached, oldest expiring buffs are overwritten first; overflow announced: "Maximum effect slots reached. Oldest effects are being replaced."
- [ ] Stacked buff effects displayed with stack count: "Blade Venom — 3 stacks — each dealing 12 poison damage per turn — 8 seconds remaining"

## Notes
Buff/debuff management is the most information-dense real-time accessibility challenge in the entire game. Marcus needs a mental model of his complete status at any moment to play at the level he expects of himself. The two-list structure (buffs then debuffs) mirrors how screen readers process live regions — it gives him a predictable traversal pattern. The assertive interrupt for control-removal debuffs (stun, silence) is justified: these are time-critical information events that require immediate awareness. Polite announcements for routine buff/debuff changes prevent the assertive channel from becoming noise. The 20-effect cap is a game balance constraint as much as a UX constraint — unlimited buff stacking creates both balance problems and SR noise. The stack count display for stackable debuffs (bleeds, poisons, charges) must be precise: "3 stacks" reads completely differently than three separate entries.
