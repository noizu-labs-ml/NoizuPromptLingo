# US-011: JAWS Screen Reader Compatibility

**Persona:** Priya — Accessibility engineer, tests with all screen readers
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Priya, I want to verify that the game is fully playable with JAWS (Freedom Scientific) so that I can confirm compatibility with the most widely used professional screen reader and write an accurate review.

## Acceptance Criteria
- [ ] All P0 accessibility criteria (US-001 through US-010) pass when tested with JAWS 2023/2024 + Chrome and JAWS + Firefox
- [ ] JAWS virtual cursor navigation (F6 to cycle frames, H for headings, L for lists, B for buttons) produces a coherent browsing experience
- [ ] JAWS forms mode activates automatically when the command input receives focus; deactivates correctly on Escape
- [ ] ARIA live region announcements fire in JAWS with both Chrome and Firefox (JAWS handles these differently per browser)
- [ ] The JAWS virtual PC cursor does not interfere with game keyboard shortcuts — shortcut conflicts are documented and configurable
- [ ] JAWS Say All (Insert+Down) can narrate the game log continuously without errors or infinite loops
- [ ] Test report documents any JAWS-specific workarounds implemented

## Notes
JAWS has the highest market share among employed blind professionals. Key differences from NVDA: JAWS inserts its own virtual buffer; `aria-live` behavior varies significantly by browser pairing; JAWS may not pick up `inert` attribute in older versions (check JAWS 2022 compatibility). Priya's review audience includes both blind users and accessibility purchasers — JAWS compat is a go/no-go signal for enterprise recommendation.
