# Review: Virtualize Chat Rooms with Thousands of Messages

- **Story**: `project-management/user-stories/US-097-virtualize-chat-room-many-messages.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No virtualization exists on the chat room surface. The room page (`frontend/src/app/app/[orgId]/chat/[roomId]/page.tsx`) fetches the full unbounded message list — `api.listChatMessages(orgId, roomId, { include_replies: true })` with no limit/window parameter (`page.tsx:310`) — and renders every message into the DOM. There is no windowing library, no virtual-list component, and no mount/unmount-by-visibility logic anywhere in `frontend/src` or `frontend/packages` (grep for virtualiz/windowing/virtual-list returns nothing). The page's `IntersectionObserver` (`page.tsx:334`) tracks a proximity sentinel for a different feature, not render windowing. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| 5,000+ message room mounts only messages near the scroll position (verified via DOM node count) | Not Met | Full-list fetch `frontend/src/app/app/[orgId]/chat/[roomId]/page.tsx:310`; all messages rendered; no virtualization code in frontend |
| Rapid scrolling through long history stays smooth (no multi-second jank) | Not Met | Entire history is mounted at once; no mounting/unmounting machinery to keep frames smooth |
| "Latest" jump after deep scroll doesn't render every intermediate message | Not Met | No jump-to-latest windowing path; all messages are already rendered, so the jump is a plain scroll over a fully-populated DOM |
| Rich-content messages (code blocks, images) re-render correctly across the virtual window | Not Met | Moot until virtualization exists; no window-state preservation logic found |

## Gaps / Risks

- Should-have epic story with zero implementation; shares the scale cliff with US-096 (board pagination) — both surfaces fetch-and-render everything.
- Backend `GET /api/chat/rooms/{room_id}/messages` does support `limit`/`before_id` cursor paging (`src/npl_mcp/api/router.py:2708-2721` in the MCP server API), so the transport-side primitive for windowed fetching exists — the client simply doesn't use it.
- Reduced-motion interplay flagged in the story's Notes (no animated pop-in on virtualized mount for reduce users) is unaddressed and should be a requirement when this lands (see US-095 review).
- No DOM-node-count or frame-rate regression test exists to verify any future implementation.

## BDD Scenario

```gherkin
Feature: Virtualize chat rooms with thousands of messages

  Scenario: Operator opens a 5,000-message room
    Given a chat room contains 5,000+ historical messages
    When Jordan opens the room
    Then only messages near the scroll position are mounted in the DOM
    And the mounted node count is bounded, not proportional to history size
    # Today: FAILS — the full history is fetched (page.tsx:310) and rendered.

  Scenario: Jordan scrolls rapidly through deep history
    When scrolling through thousands of messages
    Then frame rate stays smooth with no multi-second jank spikes

  Scenario: Jordan jumps to latest from deep in history
    When he activates "jump to latest"
    Then the view scrolls directly to the newest message
    Without rendering every intermediate message first

  Scenario: Rich message leaves and re-enters the window
    Given a message contains a code block or image
    When it scrolls out of and back into the virtualized window
    Then it re-renders correctly without losing meaningful state
```
