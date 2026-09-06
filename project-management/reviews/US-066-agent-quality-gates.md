# Review: Agent Quality Gates

- **Story**: `project-management/user-stories/US-066-agent-quality-gates.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python orchestration package implements a reusable pipeline with quality gates: `QualityGate` (name + `check_fn`) attaches to a `PipelineStage`, failures trigger bounded retries and then block the pipeline (`src/npl_mcp/orchestration/stages.py:27-63`, `src/npl_mcp/orchestration/pipeline.py:19-72`). Gate failure reason is captured on the pipeline result struct (`pipeline.py:67-72`). However, this is a generic in-process library: gates are caller-supplied functions, there is no declarative "define gate as test coverage/linting/security" surface, no persistent log of gate results, and no human-override mechanism. npl-grader provides assessment but is not wired to these gates automatically. No Elixir-backend equivalent was found. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Define quality gates as pass/fail criteria (test coverage, linting, security) | Partially Met | `src/npl_mcp/orchestration/stages.py:27-40` — arbitrary `check_fn` gates; no built-in coverage/lint/security gate definitions |
| Gates applied automatically to agent outputs | Partially Met | `src/npl_mcp/orchestration/pipeline.py:53-56` — gates apply to pipeline stage results when a pipeline is used; no automatic application to agent outputs outside a pipeline |
| Failed gates block downstream workflow steps | Met | `src/npl_mcp/orchestration/pipeline.py:54-72` — on exhausted retries the pipeline sets `error` and stops (`reason: "gate_failure"`) |
| Gate results logged with detailed failure reasons | Partially Met | `pipeline.py:67-72` stores gate name and failure on the in-memory result struct; no persistent/structured log found |
| Agents can retry after addressing gate failures | Met | `src/npl_mcp/orchestration/stages.py:52,62` — `max_retries` per stage; gate re-checked per retry (`pipeline.py:54-66`) |
| Override mechanism for human review when gates are too strict | Not Met | no evidence found (no override/skip/force flag in pipeline.py) |

## Gaps / Risks

- No standard library of named gates (tests/lint/security) — each caller reimplements `check_fn`, so "gate" semantics vary.
- Gate results are ephemeral; compliance/auditing use cases (cf. US-070) have nothing to query.
- TDD pipeline variant (`src/npl_mcp/orchestration/tdd_pipeline.py`) exists but was not verified to wire gates end-to-end.

## BDD Scenario

```gherkin
Feature: Agent quality gates

  Scenario: Failing gate blocks the pipeline then allows retry
    Given a pipeline stage whose QualityGate checks that tests pass
    And the stage output currently fails the gate
    When the pipeline executes the stage
    Then the gate is evaluated and the stage is retried up to max_retries
    When retries are exhausted
    Then the pipeline stops, records error "Gate '<name>' failed on stage '<stage>'", and no downstream stage runs

  Scenario: Human override (NOT YET POSSIBLE)
    Given a gate that is too strict for a legitimate output
    When an operator requests a human-review override
    Then no override mechanism exists in the pipeline implementation
```
