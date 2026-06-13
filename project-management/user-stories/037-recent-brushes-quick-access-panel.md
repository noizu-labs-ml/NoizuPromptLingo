# US-037: Recent Brushes Quick-Access Panel

**As a** painter who cycles between a small set of brushes during a session,
**I want to** access my recently used brushes from a compact popup panel,
**So that** I can switch between favorite brushes without navigating the full brush library.

## Personas
- **Primary:** P3 Lena Vasquez — concept art workflow uses 4-6 brushes repeatedly; full library navigation is too slow
- **Also relevant:** P1 Maya Chen, P2 David Okafor, P4 James Whitfield

## Acceptance Criteria
- [ ] A popup panel shows the last 10 brushes used (including their saved parameter state at time of last use)
- [ ] The panel is invoked via a configurable shortcut (default: `` ` ``) or a toolbar button
- [ ] Clicking a brush in the panel activates it immediately and dismisses the panel
- [ ] Each entry in the panel shows a thumbnail stroke preview of the brush and its name
- [ ] The panel supports keyboard navigation (arrow keys to select, Enter to activate, Escape to dismiss)
- [ ] Recent brush history persists across sessions (saved to user preferences)
- [ ] The panel can be pinned as a floating palette that remains visible during painting

## Notes
The recent brushes list must store a snapshot of each brush's full parameter state (size, opacity, hardness, custom parameters) at the time of last use — not just a reference to the brush definition, which may have since been edited or deleted.
