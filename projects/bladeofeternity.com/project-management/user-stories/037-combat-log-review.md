# US-037: Combat Log — Post-Fight Review and Analysis

**Persona:** Dave — Sighted MUD veteran, sysadmin, deep systems
**Priority:** P1
**Epic:** Combat — Interface

## Story
As Dave, I want a full combat log accessible after each fight that lets me review every round, action, and physics event in detail so that I can analyze my performance and optimize my tactics.

## Acceptance Criteria
- [ ] Combat log panel opens via keyboard shortcut and is a separate ARIA landmark (`role="region"`, labeled "Combat Log")
- [ ] Log organized by round; each round is a collapsible section (ARIA disclosure widget)
- [ ] Within each round: player action, opponent action(s), resolution events, damage values, status changes — all in prose
- [ ] Physics debug layer (opt-in per account) appends raw simulation values below each prose entry
- [ ] Log searchable by round number, action type, or keyword
- [ ] Export function: downloads log as plain text or JSON (JSON includes simulation values if debug mode on)
- [ ] Log persists for 24 hours after combat ends, then archived (accessible via character history)
- [ ] Log scrollable with keyboard (Page Up/Down, Home/End) and navigable by round heading

## Notes
Dave will use the log to reverse-engineer the physics engine's behavior. The JSON export must include enough simulation metadata to reconstruct the combat: random seeds, material property values, force vectors, collision normals. This is also the primary debugging surface for the development team. Consider a shareable log link (read-only, 7-day expiry) so Dave can post logs to community forums for analysis.
