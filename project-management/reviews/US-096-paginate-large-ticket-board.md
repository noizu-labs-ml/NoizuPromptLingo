# Review: Paginate Large Ticket Boards Without a Full Reload

- **Story**: `project-management/user-stories/US-096-paginate-large-ticket-board.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No pagination exists on the ticket board surface. The board is the `npl-queue-board` web component (`frontend/packages/npl-queue-board/src/npl-queue-board.ts`, 504 lines): it renders its full item set in one pass — there is no page size, no "load more" affordance, no fetch-on-scroll sentinel, and no incremental append logic (grep for page/limit/offset/slice/IntersectionObserver/load-more finds nothing). The chat-room page's IntersectionObserver (`frontend/src/app/app/[orgId]/chat/[roomId]/page.tsx:334`) is for a proximity sentinel, not board pagination, and the chat page itself also fetches the full message list unbounded (`:310`). No column-level count reconciliation against a partially loaded client state exists. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Board loads only the first page of tickets per column, with visible "load more"/fetch-on-scroll per column | Not Met | `frontend/packages/npl-queue-board/src/npl-queue-board.ts` renders all items; no page-size or load-more logic anywhere in `frontend/packages/npl-queue-board/src/` |
| Next page appends without re-fetching/re-rendering loaded tickets or resetting scroll | Not Met | No incremental-fetch or append path exists; the component is fed its full item set |
| Column counts update correctly while only some tickets are loaded client-side | Not Met | No server-side count reconciliation; counts derive from the loaded array (grouping in `frontend/packages/npl-queue-board/src/grouping.ts`) |
| 10,000+ ticket column keeps initial time-to-interactive within budget | Not Met | Full render of all items — TTI degrades linearly with ticket count; no performance test or budget guard found |

## Gaps / Risks

- This is a must-have epic-baseline story with zero implementation — the largest known scale risk on the board surface.
- The board's data provider abstraction (`frontend/packages/npl-queue-board/src/providers/`) is the natural seam for windowed fetching; no paging contract exists in it yet.
- Related stories named in the Notes (US-089 dangling-link rendering on paginated cards) are equally unaddressed on this surface.
- No benchmark or perf regression test exists to even measure the 10k-ticket scenario.

## BDD Scenario

```gherkin
Feature: Paginate large ticket boards

  Scenario: Delivery lead opens an over-sized project board
    Given a project has more tickets in a column than the initial page size
    When Priya opens the board
    Then only the first page of tickets per column is fetched and rendered
    And each column shows a "load more" affordance or fetches on scroll
    # Today: FAILS — the entire column is fetched and rendered at once.

  Scenario: Priya requests the next page in a column
    When the next page loads
    Then already-rendered tickets are neither re-fetched nor re-rendered
    And her scroll position is preserved

  Scenario: A ticket changes while the board is paginated
    When a ticket is created, moved, or deleted
    Then the column count reflects the true server-side total
    Even though not all tickets are loaded client-side

  Scenario: 10,000-ticket column performance budget
    Given a column holds 10,000+ tickets
    When the board first becomes interactive
    Then time-to-interactive stays within the agreed budget rather than scaling linearly
```
