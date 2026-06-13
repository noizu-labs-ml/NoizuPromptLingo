# US-022: Combat Action Menu — Full Keyboard Navigation

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Combat — Interface

## Story
As Marcus, I want a combat action menu that I can navigate entirely by keyboard with logical grouping and fast access shortcuts so that my reaction time in PvP is not bottlenecked by interface traversal.

## Acceptance Criteria
- [ ] Combat action menu exposed as ARIA `role="menu"` with `role="menuitem"` children
- [ ] Menu organized into groups: Attack, Defend, Skills, Items, Flee — each a `role="group"` with `aria-label`
- [ ] Number key shortcuts (1–5 for groups, then sub-keys) navigable without leaving the menu landmark
- [ ] Currently highlighted action announced with its cooldown status and MP/stamina cost
- [ ] Menu opens automatically on round start and focus lands on last-used action
- [ ] Screen reader does not re-read entire menu on each round; only changed state (cooldowns, disabled items) announced
- [ ] Escape closes menu and announces "Action cancelled — awaiting input"
- [ ] Menu remains open across rounds; state updates in-place via `aria-disabled` and `aria-label` mutation

## Notes
This is the highest-frequency interaction in the game. Optimize for zero-reflow announcements. Use `aria-atomic="false"` on the menu container so only changed children are announced. Test with NVDA browse mode vs. application mode — menu must work in application mode (forms mode) with arrow key navigation.
