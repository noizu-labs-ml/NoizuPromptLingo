# Review: Share Artifact in Chat Room

- **Story**: `project-management/user-stories/US-004-share-artifact-chat.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`share_artifact` (`src/npl_mcp/chat/chat.py:303-315`) inserts a chat event of type `artifact_share` carrying `{artifact_id, revision}` in its JSONB data, and is exposed as the `Chat.ShareArtifact` MCP tool (`src/npl_mcp/launcher.py:1348-1361`). Room membership/authz is not checked, the artifact's existence is not validated at share time, the revision parameter is stored as-is (staying `null` when omitted rather than resolving to the latest revision), and the return value is a generic `event_id` rather than a distinct `shared_artifact_id`. Consumers can retrieve the event via `Chat.Feed`/`event_list` (`chat.py:232-270`), and artifacts are viewable through the artifact tools, so end-to-end viewing is possible — but there is no inline rendering or preview surface anywhere in the repo.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Share any artifact by ID in a chat room | Met | `src/npl_mcp/chat/chat.py:303-315` via `event_create` insert into `npl_chat_events` (`chat.py:212-215`); registered `Chat.ShareArtifact` (`launcher.py:1348-1361`) |
| Optionally specify a particular revision | Met | `revision: int | None` parameter stored in event data (`chat.py:307,314`) |
| Shared artifact appears inline in chat feed | Not Met | no evidence found — feed returns raw event JSON (`chat.py:260-270`); no rendering/preview layer exists in the repo |
| Other participants can view the artifact directly | Partially Met | artifact retrieval tools exist (`get_artifact`/artifact module) and feed exposes `artifact_id`, but there is no room-membership gate so "participants" is unenforced, and no linked view endpoint |
| Sharing creates a chat event in the room's feed | Met | `event_type="artifact_share"` row in `npl_chat_events` visible via `event_list` (`chat.py:310-315`, `chat.py:232-259`) |
| Defaults to latest revision if none specified | Not Met | `revision` stays `None` in the event data — it is never resolved to the artifact's current latest revision (`chat.py:314`) |
| Returns shared_artifact_id for reference | Partially Met | returns `event_id`/`room_id` from `event_create` (`chat.py:222-229`); no distinct `shared_artifact_id`, though `event_id` is a usable reference |

## Gaps / Risks

- No validation that `artifact_id` refers to an existing artifact — shares of deleted/typo'd IDs are silently persisted.
- No room-membership or authorization check in the share path (consistent with the rest of the chat module, but the story's "other participants" framing implies one).
- "Latest revision" semantics are inverted from the story's intent: the story wants the share pinned to the latest revision at share time; the implementation pins to nothing (null = unspecified), so a viewer cannot tell which revision was meant.
- Notifications on share are not generated (story open question, unresolved).
- `room_add_member` exists (`chat.py:150`) but is never consulted by `share_artifact`.

## BDD Scenario

```gherkin
Feature: Share an artifact in a chat room
  Scenario: Vibe coder shares work for discussion
    Given a chat room and an artifact with revisions 1 and 2
    When the coder calls Chat.ShareArtifact with room_id and artifact_id
    Then an "artifact_share" event is created in the room's feed
    And the response includes an event_id usable as the share reference
  Scenario: Pinned revision
    When the share is created with revision 2
    Then the event data records artifact_id 2-tuple {artifact_id, revision: 2}
    And later revisions of the artifact do not change the recorded revision
  Scenario: Omitted revision
    When the share is created without a revision
    Then today the event stores revision null — it is not resolved to the latest revision at share time
  Scenario: Viewing the share
    When a team member lists the room feed via Chat.Feed
    Then the artifact_share event appears with its data payload
    And the member can fetch the artifact through the artifact tools by the recorded id
  Scenario: Invalid share
    When a share is created for a nonexistent artifact id
    Then today the event is still created — no existence or membership validation occurs
```
