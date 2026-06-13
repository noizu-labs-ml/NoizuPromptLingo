# US-196: Character Stat Inspection

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Marcus, I want to inspect other players' public stats — including level, class, specialization, clan, and titles — with a screen reader-friendly inspection panel and privacy settings so that I can size up opponents and allies accurately.

## Acceptance Criteria
- [ ] Inspection initiated by targeting a player character and issuing the "Inspect" command; result rendered as a structured panel with keyboard-traversable sections
- [ ] Public inspection panel sections: Character Identity (name, title, class, specialization, prestige class if applicable, level), Guild/Clan affiliation, Titles (active title displayed, total title count), Crafting Mastery summary (highest discipline tier), and Achievements (count and most recent three unlocks)
- [ ] SR reads each section on focus with full structured data: "Class: Guardian Warrior, Level 24 — Specialization: Guardian — Prestige: not yet achieved"
- [ ] Privacy settings controlled by inspected player: each section individually togglable (hide clan, hide achievements, hide crafting mastery); hidden sections display "Private" in inspection panel with SR announcement
- [ ] Attribute stats (Strength, Agility, etc.) not exposed in default inspection to protect build privacy; players may opt-in to "open build" mode sharing full attribute sheet
- [ ] Combat statistics (kill/death ratio, PvP wins) optional disclosure controlled by inspected player; relevant for Marcus's PvP assessment
- [ ] Inspection panel opens as an accessible modal dialog (focus trapped, Escape closes, returns focus to previous element per US-007 focus management standards)
- [ ] Inspection history: player can view last 10 inspected characters via an inspection log accessible from character menu; log navigable by keyboard with SR-readable entries

## Notes
Marcus uses inspection as a competitive intelligence tool before engaging in PvP. The privacy model is essential: players deserve control over what they reveal. The default inspection reveals identity and accomplishments (titles, clan, level, class) while protecting build secrets (attributes, combat stats) — this balance lets Marcus see whether someone is worth fighting while respecting their strategic privacy. The "open build" opt-in is for players who want to be transparent, like Priya (accessibility advocate) who may share her character's build configuration for community research. The inspection history is a small but appreciated feature for Marcus, who may inspect 20 players in a PvP session and want to re-check one without re-navigating to find them. Ensure inspection modal is interruptible — combat should break the modal with appropriate ARIA notification.
