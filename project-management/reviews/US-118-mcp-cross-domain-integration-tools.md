# Review: MCP Cross-Domain Integration Tools

- **Story**: `project-management/user-stories/US-118-mcp-cross-domain-integration-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The two linking primitives exist in both codebases, but usage tracking is absent. Python: `task_add_artifact`/`task_list_artifacts` (src/npl_mcp/tasks/tasks.py:401-462) link artifacts or git branches to tasks via `npl_task_artifacts`, and `share_artifact` (src/npl_mcp/chat/chat.py:303-315) posts an `artifact_share` event to a room (launcher tools Tasks.AddArtifact/ListArtifacts, Chat.ShareArtifact). Elixir backend (noted: Elixir backend at /Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend): `Ticket.Attach` attaches artifacts/URLs/branches to tickets (domains/tickets/tools/ticket_attach.ex) and `Chat.Attach` shares an artifact in a room (domains/chat/tools/chat_attach.ex); org/project resolution gives artifacts, tickets, and rooms a shared namespace (e.g., artifact_create.ex resolves organization + project before insert). What is missing in both: no artifact-usage index or query that answers "where is this artifact used across chat and tasks", and no mechanism that carries task context into a chat share or vice versa — every cross-domain link is a manual, disconnected call.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Link artifacts to tasks across domains | Met | `task_add_artifact` + `task_list_artifacts` src/npl_mcp/tasks/tasks.py:401-462; Elixir backend `Ticket.Attach` domains/tickets/tools/ticket_attach.ex |
| Share artifacts in chat from task context | Partially Met | Sharing exists (`share_artifact` chat.py:303-315; Elixir `Chat.Attach` chat_attach.ex) but the call takes only room/artifact ids — no task-context parameter, and no tool derives a share from a task's linked artifacts |
| Track artifact usage across chat and tasks | Not Met | No usage/back-reference tracking in either codebase: artifact shares store only ids in event JSON, artifact tables have no usage counters or reverse lookups (grep for usage/backlink/track across `src/npl_mcp/` and backend `lib/` finds nothing) |
| Workflow continuity maintained across domains | Partially Met | Shared org/project scoping on the Elixir backend (Resolve.organization_id / project_in_org in artifact and ticket tools) and session/chat-room linkage on queues (`task_queue_create(session_id, chat_room_id)` tasks.py:240-263) provide a connective spine; Python-side access is fully unscoped and no explicit continuity mechanism (e.g., context handoff) exists |

## Gaps / Risks

- The story's headline feature — usage tracking across domains — has no implementation at all; an artifact shared into 5 rooms and linked to 3 tasks looks identical to an unused one.
- Python cross-domain ids are unscoped integers with no existence checks: `task_add_artifact` accepts any task_id/artifact_id, and `share_artifact` accepts any room_id (no FK validation observed at the call layer).
- Links are one-directional and denormalized (artifact ids embedded in chat-event JSON), so deleting or re-versioning an artifact leaves stale references with no reconciliation.
- Elixir `Ticket.Link` entity types (ticket_link_entity.ex) cover marketing entities (personas, campaigns, keywords) but not artifacts — artifact↔ticket linking goes only through `Ticket.Attach`.

## BDD Scenario

```gherkin
Feature: Cross-domain artifact integration

  Scenario: Link a diff artifact to a task and share it in the war room
    Given an artifact "authz-fix.diff" exists
    When the agent calls ToolCall("Tasks.AddArtifact", {"task_id": 88, "artifact_type": "artifact", "artifact_id": 41})
    Then the link is stored in npl_task_artifacts and listed by Tasks.ListArtifacts
    When the agent calls ToolCall("Chat.ShareArtifact", {"room_id": 7, "persona": "team-lead", "artifact_id": 41})
    Then an artifact_share event appears in room 7
    # Missing today: no query returns "artifact 41 is used by task 88 and rooms 7, 9".

  Scenario: Attach an artifact to a ticket with shared scoping (Elixir backend)
    Given an artifact created under organization "acme", project "platform"
    When an agent calls Ticket.Attach with the artifact reference
    Then the attachment is stored on the ticket within the same organization/project scope
```
