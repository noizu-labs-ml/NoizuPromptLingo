# Review: Pair Program via Chat Room

- **Story**: `project-management/user-stories/US-036-pair-program-via-chat.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python MCP server provides a functional chat surface: rooms with membership (`src/npl_mcp/chat/chat.py:9-200`), messages (`chat.py:95-110`), generic events with `reply_to_id` threading and emoji reactions (`chat.py:201-286`), todo events (`chat.py:288-300`), artifact-share events (`chat.py:303-315`), and notification list/mark-read (`chat.py:318-380`), all exposed as MCP tools (`src/npl_mcp/launcher.py:1190-1380`). Message content is free text, so markdown code blocks pass through. The missing pieces are the collaboration glue: nothing generates notifications on @mention (the notifications table is write-free in current code), no real-time push exists (no websocket/SSE in `src/npl_mcp/api/router.py` — clients must poll), artifact revisions do not link back to chat discussions, and message-level replies are not wired into `message_create` (threading exists only on events).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Multi-party chat (2+ participants, humans and agents) | Met | room members are persona slugs (`chat.py:150-200`); messages carry any author (`chat.py:95-110`) |
| Code snippet sharing with markdown code blocks via `send_message` | Met | content stored verbatim; rendering is client-side (`chat.py:95-110`) |
| Agent @mentions include them in conversation context | Not Met | no mention parsing or subscription anywhere in `chat.py` or `launcher.py` |
| Inline artifact preview in chat feed with metadata | Partially Met | `share_artifact` records artifact_id+revision as an event (`chat.py:303-315`); feed shows the reference, and preview rendering/resolution is not provided server-side |
| Agent context persistence (history on subsequent messages) | Met | full history retrievable via `Chat.ListMessages`/`Chat.ListEvents` (`chat.py:62-94, 232-275`) |
| Quick todo creation via `create_todo` | Met | `chat.py:288-300`; tool `Chat.CreateTodo` at `launcher.py:1325` |
| Real-time concurrent sends without loss | Partially Met | DB-backed inserts are concurrency-safe (`chat.py:101-105`), but there is no realtime channel — no websocket/SSE found in `src/npl_mcp/api/router.py`; polling only |
| New artifact revisions link back to chat discussion | Not Met | no evidence found linking revisions to rooms/events |
| Message threading via event_id reference | Partially Met | events support `reply_to_id` (`chat.py:201-231`), but `message_create` (the `send_message` path) has no reply parameter (`chat.py:95-110`) |
| @mentioned participants receive notifications | Not Met | notifications can be listed/read (`chat.py:318-380`) but nothing ever creates them — no mention-triggered generation |

## Gaps / Risks

- The notifications subsystem is dormant: read-only against a table with no writer. Any story assuming mention alerts (this one, US-051 notification preferences) is blocked on notification generation.
- Threads exist for events but not for messages, while the story's primary flow (`send_message`) is message-based — the two paths should be unified.

## BDD Scenario

```gherkin
Feature: Pair Program via Chat Room

  Scenario: Pairing session with todos and shared artifacts
    Given Dave and an AI agent are members of a chat room
    When Dave calls Chat.SendMessage with a markdown code block
    And the agent calls Chat.ShareArtifact for a test file it created
    And Dave calls Chat.CreateTodo "Review test coverage"
    Then all three are persisted in the room and retrievable via Chat.ListMessages and Chat.ListEvents

  Scenario: Mention-triggered notification (not available)
    Given the agent is a room member
    When Dave sends a message containing "@ai-agent"
    Then no notification is generated for the agent
    And Chat.Notifications returns only rows that some future writer created
```
