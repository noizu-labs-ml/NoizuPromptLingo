# US-012: Configurable Screen Reader Verbosity

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want to configure exactly what the game announces and how verbosely so that I can optimize for PvP reaction time by silencing flavor text while keeping combat-critical announcements instant.

## Acceptance Criteria
- [ ] A verbosity settings panel (keyboard accessible) offers independent toggles for: combat events, NPC dialogue, environmental descriptions, system messages, party chat, zone announcements, item pickup, XP/level events
- [ ] Each category has three levels: Off / Summary / Full (e.g., Full combat = all hit/miss/damage; Summary = damage only; Off = silent)
- [ ] Settings take effect immediately without page reload
- [ ] A "PvP Mode" preset applies recommended competitive settings (assertive combat, silent narrative)
- [ ] A "Exploration Mode" preset restores full narrative verbosity
- [ ] Custom presets can be saved and named (up to 5 presets per account)
- [ ] Current verbosity preset is announced when changed: "Switched to PvP Mode"
- [ ] Settings are stored server-side and sync across sessions and devices

## Notes
This is a differentiator from generic accessible games — treating blind players as power users who want control, not just minimum compliance. The preset system is especially important for Marcus's PvP context. Verbosity settings must operate at the application layer (what gets injected into live regions), not by muting the screen reader externally.
