# US-002: Complete Keyboard-Only Navigation

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want every game function reachable and operable via keyboard alone so that I never need a mouse to play, and can build muscle-memory hotkeys for competitive PvP.

## Acceptance Criteria
- [ ] All interactive elements (abilities, inventory, map, chat, menus) are reachable via Tab / Shift+Tab with a logical DOM order matching visual layout intent
- [ ] All custom widgets (ability bars, context menus, radial selectors) implement ARIA keyboard patterns per APG (arrow keys within composites, Escape to close, Enter/Space to activate)
- [ ] No keyboard trap exists anywhere in the application — Escape always provides an exit path
- [ ] Focus is never lost to `document.body` after an action; it is moved to the next logical target (e.g., after closing a modal, focus returns to the trigger)
- [ ] A visible focus indicator with minimum 3:1 contrast ratio against all backgrounds is present at all times (for low-vision users sharing the keyboard pattern)
- [ ] All drag-and-drop interactions (inventory rearrangement, hotbar assignment) have a keyboard-equivalent workflow

## Notes
Custom ability bars are the highest-risk component for keyboard trap and ARIA composite pattern violations. The APG "Toolbar" pattern is the recommended baseline. Audit with keyboard-only, screen reader off, as a separate test pass to catch visual-only focus indicators.
