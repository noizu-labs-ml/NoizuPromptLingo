# US-042: Screen Reader Room Navigation Commands

**Persona:** Marcus — Blind Power Gamer (NVDA + Firefox, 90WPM)
**Priority:** P0
**Epic:** World & Exploration

## Story
As Marcus, I want to navigate rooms using fast keyboard commands and receive structured, non-redundant output so that I can move through the world at speed without re-listening to full descriptions on every step.

## Acceptance Criteria
- [ ] `look` command outputs full room description (name, description, exits, NPCs, items)
- [ ] `exits` command outputs only available exits, formatted as a brief list
- [ ] `glance` command outputs a one-sentence summary (room name + NPC count + item count)
- [ ] Moving via direction command (`n`, `s`, `e`, `w`, `u`, `d`) announces only the destination room name and exit count by default
- [ ] After movement, full description is available on demand via `look` without re-triggering
- [ ] All output regions use correct ARIA roles (`role="log"` for command output, `aria-live="polite"` for room changes)
- [ ] No duplicate announcements — moving to a room does not trigger both movement text and full description via ARIA live
- [ ] User can toggle "verbose move" mode (full description on every move) via `/set verbose-move on`

## Notes
- Marcus types at 90WPM; command latency must be under 100ms for navigation responses
- NVDA+Firefox interaction tested explicitly — some ARIA live region patterns behave differently across screen reader/browser combos
- "glance" command is Marcus's fast situational awareness tool during PvP traversal
- Verbose mode off by default; power users toggle it on
