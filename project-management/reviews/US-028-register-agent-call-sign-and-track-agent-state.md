# Review: Register an agent call sign and track agent state

- **Story**: `project-management/user-stories/US-028-register-agent-call-sign-and-track-agent-state.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No call-sign or agent-state tracking exists. Greps for `call_sign`, `callsign`, `agent_state`, and `roster` across `src/` and `tests/` return nothing. There is no persona registry with a state field or last-updated timestamp: `src/npl_persona/` is a file-based persona-definition library (templates, parsers, journal) with no runtime liveness tracking, and `src/npl_mcp/` has no persona registration or roster query tools. Staleness flagging has no counterpart anywhere.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Call sign validated for uniqueness within org/project scope and attached to persona record | Not Met | no evidence found |
| State updates reflected on persona with last-updated timestamp | Not Met | no evidence found |
| Roster query shows call sign, current state, last-updated without opening sessions | Not Met | no evidence found |
| Stale agents (no update within window) flagged rather than shown active | Not Met | no evidence found |

## Gaps / Risks

- No persona storage model to extend: this needs a new table/collection plus registration, state-update, and roster-query tools.
- Uniqueness scoping depends on org/project fields that the current persona/tool-session models do not carry consistently — design work required before implementation.
- Staleness detection implies a clock-compared computed field or periodic sweep; neither mechanism exists in the codebase.

## BDD Scenario

```gherkin
Feature: Register agent call sign and track state

  Scenario: Register and update state
    Given the agent's persona is registered
    When the agent registers call sign "SABLE" and sets state to "working"
    Then the persona record shows call sign "SABLE", state "working", and a last-updated timestamp
    And a roster query lists it without opening individual sessions

  Scenario: Stale agent flagged
    Given an agent whose state has not updated within the staleness window
    When the administrator views the roster
    Then that agent is flagged as stale/possibly-disconnected
```

(Scenario describes target behavior — none of it is executable today.)
