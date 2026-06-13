# US-008: Screen Reader Accessible Character Status Panel

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want my character's HP, MP, and status effects announced accurately and on-demand so that I can make informed combat decisions without relying on visual HP bars.

## Acceptance Criteria
- [ ] Character HP, MP, and stamina are exposed as ARIA `progressbar` elements with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, and `aria-valuetext` (e.g., "Health: 847 of 1200, 71%")
- [ ] A dedicated keyboard shortcut (e.g., Alt+S) reads the full status summary without moving focus from the current element
- [ ] Active status effects (buffs/debuffs) are listed in an `<ul>` within the status panel with each effect as an `<li>` including name and remaining duration
- [ ] When HP drops below configurable thresholds (e.g., 50%, 25%), an `aria-live="assertive"` announcement fires: "Warning: Health at 23%"
- [ ] Status effect application and expiration are announced via `aria-live="polite"` (e.g., "Poison applied. Regeneration expired.")
- [ ] The status panel is reachable via landmark navigation as `<aside aria-label="Character status">`
- [ ] Numeric values update in real time without requiring focus on the panel

## Notes
ARIA progressbar with `aria-valuetext` is critical — screen readers otherwise read raw percentages without context. The shortcut key (Alt+S) must not conflict with NVDA or JAWS passthrough mode. Consider an "announce on change only" vs "announce always" toggle for users who want to minimize interruptions during non-combat periods.
