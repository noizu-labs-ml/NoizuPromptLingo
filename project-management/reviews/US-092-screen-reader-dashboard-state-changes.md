# Review: Announce Dashboard State Changes to Screen Readers

- **Story**: `project-management/user-stories/US-092-screen-reader-dashboard-state-changes.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Scattered `aria-live` usage exists in the legacy app: session status/error announcements on the session detail page (`frontend/legacy-app/sessions/[uuid]/SessionDetailClient.tsx:292`, `aria-live="polite"`) and task errors (`frontend/legacy-app/tasks/page.tsx:190`, `role="alert" aria-live="polite"`), plus a few components in the new frontend (`frontend/src/components/shell/CommandPalette.tsx`, `frontend/src/components/console/DataTable.tsx`). There is no dashboard-level live-region strategy: no live region that announces session/ticket transitions at the dashboard scope, no announcement queue or priority handling for rapid successive changes, no audit showing visual-only indicators have aural equivalents, and no stale-backlog suppression on refocus. Confidence: medium-high (static analysis only; no runtime audit performed).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Session state transitions announced via aria-live identifying session + event | Partially Met | `SessionDetailClient.tsx:292` announces status/errors on that one page; no dashboard-wide region announcing transitions across sessions |
| Rapid successive changes are queued, not dropped or overlapping | Not Met | no evidence found — no queue/priority/aria-live assertion management anywhere in `frontend/src` or `legacy-app` |
| No state change remains visual-only | Not Met | no evidence found — no audit artifacts or announcement hooks for color-pulse-style indicators |
| Returning to the tab fires no stale announcement backlog | Not Met | no evidence found — no cleanup/debounce on visibility/focus events |

## Gaps / Risks

- The legacy pages carrying aria-live are separate from the new `frontend/src` app shell; porting or a shared announcement utility is needed before any dashboard-wide strategy is possible.
- `aria-live="polite"` on an error line (`tasks/page.tsx:190`) is arguably `assertive`; mixing without a policy is exactly the talk-over risk the story targets.

## BDD Scenario

```gherkin
Feature: Announce dashboard state changes to screen readers

  Scenario: Monitor running agents with a screen reader (today)
    Given Jordan's screen reader is active on the legacy session detail page
    When the session status text changes in place
    Then the polite live region at SessionDetailClient.tsx:292 may announce it
    But no dashboard-level region announces other sessions' transitions
    And three rapid changes can talk over each other with no queue
    And switching away and back re-fires whatever text is in the region
```
