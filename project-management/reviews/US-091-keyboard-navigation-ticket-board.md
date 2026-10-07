# Review: Full Keyboard Navigation of the Ticket Board

- **Story**: `project-management/user-stories/US-091-keyboard-navigation-ticket-board.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The ticket board exists as a Next.js page (`frontend/src/app/app/[orgId]/boards/[boardId]/page.tsx`), but it contains no keyboard interaction code: grep for `onKeyDown`, `tabIndex`, `Escape`, and arrow-key handlers returns nothing, and no drag-and-drop handlers (`onDragStart`/`onDrop`/`draggable`) are present either — so the mouse baseline the story wants keyboard equivalents for is itself not visibly implemented on this page. No global keyboard-shortcut layer, focus-management utility, or roving-tabindex component exists in `frontend/src`. The only keyboard handling found in the frontend is the CommandPalette (`frontend/src/components/shell/CommandPalette.tsx`), unrelated to the board. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Tab/Shift+Tab moves focus between cards and column headers with visible focus ring | Not Met | no focus management or tabIndex usage in `boards/[boardId]/page.tsx` |
| Documented key combo moves a focused ticket between columns/positions | Not Met | no evidence found; no move action bound to keyboard anywhere |
| Enter opens detail with focus trapped/moved in, Escape returns focus | Not Met | no evidence found |
| Every drag-and-drop action has a keyboard equivalent | Not Met | no drag-and-drop handlers found on the board page at all — neither modality is implemented |

## Gaps / Risks

- The board page appears to be a read-only/shell surface today; card movement between columns is not implemented in either mouse or keyboard form, so "keyboard equivalent to every drag action" is blocked on the drag baseline itself.
- No shared focus-announcement hook exists to satisfy the US-092 pairing ("new position is announced per US-092").

## BDD Scenario

```gherkin
Feature: Keyboard navigation of the ticket board

  Scenario: Triage the board with keyboard only (today)
    Given Priya opens a board at /app/[orgId]/boards/[boardId]
    When she tabs through the page
    Then focus moves only through native browser tab stops, if any
    And no key combination moves a ticket between columns
    And no card can be opened into a detail panel with focus management
    And no drag equivalent exists for the mouse either
```
