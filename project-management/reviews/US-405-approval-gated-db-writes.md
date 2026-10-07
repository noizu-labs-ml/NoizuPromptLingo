# Review: Gate database writes behind explicit approval

- **Story**: `project-management/user-stories/US-405-approval-gated-db-writes.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No mutating DB tool exists at all — there is no write path to gate, no approval record store, no TTL, no kill-switch config. This is consistent with the story's own sequencing note (read-only cluster US-401…404 ships first). The story's directive to "reuse the platform's existing approval-pattern primitives" has a real, adjacent anchor: the Elixir MCP layer already implements authorization step-up with human-in-the-loop elevation — `ToolGuard.before_call` returning an `elevation_uri` surfaced as an `insufficient_authorization` error (`backend/lib/noizu_prompt_lingua/mcp/dispatch.ex:28-46`) — but that gates tool authorization, not statement-level write approval, and nothing persists an approver identity/timestamp against a statement. The transactional guarantees (rollback-on-failure recorded against the approval) have no implementation anywhere. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Unapproved write rejected with "approval required" + statement/scope preview | Not Met | no evidence found — no write path exists in `src/npl_mcp` or `backend/lib` |
| Approved write executes once, recorded with approver identity and timestamp | Not Met | no evidence found |
| Expired-TTL or mismatched-statement approval rejected | Not Met | no evidence found |
| Failed approved write rolls back and records failure against approval | Not Met | no evidence found |
| Deployment-level kill-switch rejects writes unconditionally | Not Met | no evidence found — no such config exists in this repo or the Elixir backend config |

## Gaps / Risks

- The ToolGuard elevation flow (`dispatch.ex:28-46`) is the right reuse anchor, but its current semantics are per-call authorization (deny + elevation URI), not "approve this exact statement, then run it once." An implementation must add statement canonicalization + one-shot consumption; do not assume elevation ≈ approval.
- Kill-switch needs to live above the approval layer (reject regardless of approval state) — easy to get wrong if implemented as a toolset/flag toggle that only removes the tool from negotiation while a stale approval remains replayable.
- Rollback verification requires the write path to use explicit transactions; the existing internal write helpers in this repo (e.g., `src/npl_mcp/storage/metrics.py`) are single-statement best-effort and are not a template for this.

## BDD Scenario

```gherkin
Feature: Approval-gated DB writes

  Scenario: Unapproved write is rejected with a preview
    Given the DB write tool is enabled for the deployment
    When an agent submits "UPDATE tickets SET status = 'closed' WHERE id = 42"
    Then the tool responds "approval required"
    And the response previews the exact statement and its affected scope (1 row, table tickets)

  Scenario: Approved write executes once and is recorded
    Given a Delivery Lead approved the exact statement above
    When the write executes
    Then it completes exactly once
    And the execution is recorded with the approver identity and timestamp

  Scenario: Expired or altered approval is rejected
    Given an approval with a 15-minute TTL that expired 5 minutes ago
    When execution of the approved statement is attempted
    Then it is rejected
    And when a different statement is submitted citing a valid approval
    Then it is also rejected (statement mismatch)

  Scenario: Mid-execution failure rolls back
    Given an approved multi-row write fails partway through
    When the error occurs
    Then the transaction rolls back (no partial writes)
    And the failure is recorded against the approval record

  Scenario: Kill-switch overrides everything
    Given the deployment's write path is disabled by config
    When any write is submitted, even with a valid unexpired approval
    Then it is rejected unconditionally
```
