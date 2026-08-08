---
id: US-091
title: "Full Keyboard Navigation of the Ticket Board"
slug: "keyboard-navigation-ticket-board"
personas: [P-003]
epic: "Accessibility & Internationalization"
priority: "must-have"
complexity: "M"
tags: [accessibility, keyboard, ticket-board, wcag]
---

# US-091: Full Keyboard Navigation of the Ticket Board

## User Story

**As** Priya Anand, the Delivery Lead (P-003),
**I want to** move tickets between columns, open ticket detail, and reorder priorities entirely from the keyboard,
**So that** I'm not forced into drag-and-drop mouse interactions when triaging a large board quickly or working under a mobility constraint.

## Acceptance Criteria

- [ ] Given the ticket board has focus, when Priya presses Tab/Shift+Tab, then focus moves between ticket cards and column headers in a logical, visible order with a visible focus ring at every stop.
- [ ] Given a ticket card has focus, when Priya presses a documented key combination to move it, then the ticket moves to the adjacent column/position without a mouse drag, and the new position is announced per US-092.
- [ ] Given a ticket card has focus, when Priya presses Enter, then the ticket detail panel opens with focus moved into it, and Escape returns focus to the originating card with no focus loss to the page body.
- [ ] Given the board is tested with keyboard only and no mouse, when every drag-and-drop action is attempted, then each one has a working keyboard equivalent.

## Notes

Must-have because Priya's role depends on fast board triage; this is foundational for WCAG 2.1 operable criteria. Pairs tightly with US-092 for the announcement half of the interaction.
