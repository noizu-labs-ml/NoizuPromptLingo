# US-009: Navigable Game Log with Screen Reader Review Mode

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want to review the scrollback game log with my screen reader's browse/review mode so that I can re-read missed combat events or narrative text without losing my place in the live game.

## Acceptance Criteria
- [ ] The game log is a `role="log"` region with `aria-live="polite"` and `aria-label="Game log"`
- [ ] Each log entry is a `<p>` element (not a `<div>`) appended to the log in DOM order — oldest at top, newest at bottom
- [ ] The log is scrollable and navigable by NVDA/JAWS virtual cursor (up/down arrow in browse mode) without triggering game actions
- [ ] A keyboard shortcut (e.g., Alt+L) moves focus into the log at the most recent entry, enabling browse mode review
- [ ] A second press of Alt+L (or Escape from log) returns focus to the command input
- [ ] Log entries are timestamped with a visually hidden `<time>` element for screen reader users who review history
- [ ] A "Clear log" button (keyboard accessible) is available; clearing is announced via live region: "Game log cleared"
- [ ] Log length is capped (e.g., 500 entries) with oldest entries pruned from DOM to prevent performance degradation

## Notes
The tension between `aria-live` (auto-announce new entries) and virtual cursor review (user navigates backward) is fundamental. Recommend pausing live announcements when the user has moved focus into the log, and resuming when they exit. This prevents the screen reader from jumping the cursor forward while the user is reading history. Test with NVDA in both browse mode and application mode.
