# Review: Real-Time Agent Workflow Failure Diagnostics

- **Story**: `project-management/user-stories/US-048-real-time-agent-workflow-failure-diagnostics.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

An in-memory orchestration skeleton exists but none of the diagnostics surface the story requires. `src/npl_mcp/orchestration/` defines the five-stage TDD pipeline (`tdd_pipeline.py:58-95`: discovery → specification → test_creation → implementation → debug, with quality gates) and a per-stage status model (`stages.py:89-100` `to_dict` with status/timestamps/retries; `pipeline.py:88-95` aggregated `status()`). However: stages are MVP stubs that "record intent" and always mark PASSED (`stages.py:70-86`), so real agent failures never occur inside the framework; the only tool exposure is `Orchestration.Execute` (`launcher.py:1449-1490`), which runs a pipeline synchronously and discards the instance — no tool or route calls `status()` on a live or past run, and nothing persists runs. There is no workflow dashboard anywhere (`src/npl_mcp/web/` is empty; no `/logs` or diagnostics route in `api/router.py`), no `worklog.jsonl` implementation (exists only in archived PRDs, e.g. `project-management/PRDs/PRD-012-multi-agent-orchestration/README.md:368`), no artifact-blockage indication, and no restart-from-stage. No real-time (SSE/websocket) mechanism exists for any of this.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Workflow dashboard shows agent pipeline status (idea-to-spec → … → tdd-debugger) | Not Met | no dashboard (`src/npl_mcp/web/` empty); stage chain exists only in code (`tdd_pipeline.py:58-95`), exposed through no status tool or route |
| Failed agents display error type, timestamp, blocked dependencies | Not Met | stages cannot fail in the MVP (`stages.py:70-86` always passes); `to_dict` carries no error field (`stages.py:89-100`); pattern-level `error` string exists (`patterns.py:20,54`) but is surfaced nowhere |
| Click-through to agent worklog entries (`worklog.jsonl`) with cursor navigation | Not Met | no worklog implementation (grep: only PRD prose references) |
| Visual indication of which PRD/test/implementation artifact caused the block | Not Met | no artifact linkage in stage results or any UI |
| Ability to restart from failed stage after resolution | Not Met | `Orchestration.Execute` always creates a fresh instance and runs from stage 0 (`launcher.py:1480-1489`); no stage-level restart |

## Gaps / Risks

- The foundation is a scaffold, not a runner: PipelineStage.run() records intent and passes, so "failure diagnostics" has no failure source to diagnose — real agent execution must land first (or feed from the external Claude Code agents this repo actually uses).
- Status is ephemeral by design (`OrchestrationPattern.__init__` per-run UUID, `patterns.py:36-41`); persistence (a runs/stages table) is a prerequisite for dashboards, click-through, and restart.
- If implemented, the tool-call metrics tables (`npl_tool_calls`, `npl_tool_errors` — see US-049 review) and the orphaned `npl_task_events` feed are the natural instrumentation anchors; the story's `worklog.jsonl` file-based design conflicts with the Postgres storage direction.

## BDD Scenario

```gherkin
Feature: Real-time agent workflow failure diagnostics

  Scenario: PM inspects a failed workflow (not implemented)
    Given a multi-agent workflow run blocked at the implementation stage
    When the PM opens the workflow dashboard
    Then no dashboard exists — pipeline status lives only in memory inside
    Orchestration.Execute and is discarded when the call returns
    And stage failures cannot occur because stage runners always mark PASSED

  Scenario: Restart from failed stage (not implemented)
    When the PM resolves the blocker and clicks "restart from stage"
    Then no such control exists — re-execution starts a brand-new run from
    the first stage with no memory of the failed one
```

(Scenario describes target behavior — none of it is executable today.)
