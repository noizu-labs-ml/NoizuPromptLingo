# US-004: Consistent Heading Hierarchy for Screen Reader Navigation

**Persona:** Priya — Accessibility engineer, tests with all screen readers
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Priya, I want the game UI to use a strict, logical heading hierarchy so that screen reader users can navigate by heading (H key in NVDA/JAWS) to quickly orient within the game interface.

## Acceptance Criteria
- [ ] A single `<h1>` exists per page, identifying the current zone or screen (e.g., "Ashenveil Forest — Combat")
- [ ] Major sections (Character Status, Ability Bar, Game Log, Chat, Inventory) are introduced with `<h2>` elements
- [ ] Subsections within panels (e.g., "Equipped Items" within Inventory) use `<h3>`
- [ ] No heading levels are skipped (h1 → h2 → h3, never h1 → h3)
- [ ] Decorative or purely visual section dividers are not implemented as headings
- [ ] NVDA heading list (Insert+F7 → Headings) produces a scannable outline of the current game screen
- [ ] Dynamic content updates (zone transitions, combat start/end) update the `<h1>` content and announce via live region to signal context change

## Notes
The game log (scrolling text output) should NOT use heading tags for each message line — headings are for navigational structure only. Use `<p>` or `<li>` for log entries. Zone transitions are the highest-risk moment for h1 stale content — ensure the h1 is updated server-side in the Next.js page component, not via client patch.
