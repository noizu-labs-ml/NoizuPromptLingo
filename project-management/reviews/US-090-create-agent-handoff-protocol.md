# Review: Create Agent Handoff Protocol

- **Story**: `project-management/user-stories/US-090-create-agent-handoff-protocol.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No handoff protocol exists in either codebase. Repo-wide search for `initiate_handoff`, `receive_handoff`, and any handoff message schema finds only a stale test comment referencing a "W8 handoff" (`backend/test/noizu_prompt_lingua/oauth/client_toolsets_test.exs:5`) — organizational, not functional. The story's own Implementation Notes concede "handoff protocol not formalized." The closest adjacent capability is the Tasker executor system (`src/npl_mcp/executors/manager.py`), which delegates subtasks but has no context/ownership transfer semantics, and `docs/arch/agent-orchestration.md` contains no handoff section. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Define handoff message format with context, artifacts, state summary | Not Met | no evidence found |
| `initiate_handoff` tool | Not Met | no evidence found in `src/npl_mcp/` tool registrations or Elixir MCP tools |
| `receive_handoff` tool | Not Met | no evidence found |
| Handoff includes task queue, chat history, artifacts, constraints | Not Met | no evidence found |
| Conditional handoffs (condition, else fallback agent) | Not Met | no evidence found |
| Acknowledgment and cleanup protocol | Not Met | no evidence found |
| Handoff audit trail and SLA for completion time | Not Met | no evidence found |

## Gaps / Risks

- Multi-agent chains today rely on ad-hoc chat/session conventions with no guaranteed context transfer; the orchestration workflow in CLAUDE.md (idea-to-spec → prd-editor → tdd-tester → …) has no protocol backing for state handoff between phases.
- Any future implementation must decide between the Python tasker substrate and the Elixir session/chat substrate — no shared schema exists.

## BDD Scenario

```gherkin
Feature: Agent handoff protocol

  Scenario: Attempt to hand off work today
    Given an agent holding session context and artifacts mid-task
    When it tries to transfer ownership to a specialist agent
    Then no handoff tool exists to call
    And the only options are informal chat messages or shared session rows
    And there is no acknowledgment, fallback, or audit trail
```
