# Review: Define Multi-Agent Orchestration Patterns

- **Story**: `project-management/user-stories/US-079-define-multi-agent-orchestration-patterns.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Documentation-first story. `docs/arch/agent-orchestration.md` (410 lines) documents ONE pattern end-to-end — the TDD pipeline (idea-to-spec → prd-editor → tdd-tester → tdd-coder → tdd-debugger) with phases, controller responsibilities, error recovery, a JSON communication protocol, and state persistence. On the code side, `src/npl_mcp/orchestration/patterns.py` provides an `OrchestrationPattern` ABC with a `RunStatus` state machine (pending/running/complete/failed) and a `PATTERN_REGISTRY`, but only one concrete pattern is registered (`PipelinePattern`, `src/npl_mcp/orchestration/pipeline.py:17-21`). Executor-level controls exist: `Tasker.Spawn` supports `timeout_minutes`/`nag_minutes` for hung-agent handling (`src/npl_mcp/launcher.py:1690-1720`), and `src/npl_mcp/structured_logging.py` plus mise `test-status`/`test-failures` tasks cover telemetry. What the story asks for that does not exist: 5+ documented patterns (sequential exists; parallel/conditional/feedback-loop are not formally specified), a formal state machine for agent transitions, naming-convention spec, and runnable examples per pattern. No dedicated tests for pattern orchestration contracts beyond `tests/test_orchestration.py`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Document 5+ orchestration patterns (sequential, parallel, conditional, feedback loops) | Not Met | `docs/arch/agent-orchestration.md` documents the TDD pipeline only; one registered pattern (`src/npl_mcp/orchestration/pipeline.py:17-21`) |
| Define state machine for agent transitions | Partially Met | `RunStatus` enum pending/running/complete/failed (`src/npl_mcp/orchestration/patterns.py:17-23`); no agent-level transition model documented |
| Establish naming conventions for agent types and modes | Partially Met | de-facto `npl-*` naming across `.claude/agents/`, but no formal specification document found |
| Create handoff protocol specification with error handling | Partially Met | `docs/arch/agent-orchestration.md:367-402` ("Controller Responsibilities", "Error Recovery", "Communication Protocol" with JSON request/response shapes) — single-pattern, not general |
| Design failure recovery procedures for hung or timeout agents | Partially Met | `Tasker.Spawn` timeout_minutes/nag_minutes auto-terminate/nag (`src/npl_mcp/launcher.py:1690-1720`); debug-loop routing documented (`agent-orchestration.md:247-294`) |
| Specify logging and telemetry requirements for agent chains | Partially Met | `src/npl_mcp/structured_logging.py`; mise `test-status`/`test-failures` conventions in docs — no chain-level telemetry spec |
| Provide runnable examples for each pattern type | Not Met | one worked workflow (PRD-driven implementation, `agent-orchestration.md:66-96`); no runnable examples for the other pattern types |

## Gaps / Risks

- The pattern registry (`PATTERN_REGISTRY`) exists but is nearly empty — the abstraction outruns the content; nothing validates "5+ patterns" will fit it.
- No formal state machine means handoff/timeout behavior is convention, not contract — two agents can diverge on interpretation.
- Naming conventions live in tribal knowledge (`CLAUDE.md`, agent dirs), not a referenced spec this story can point to.

## BDD Scenario

```gherkin
Feature: Multi-agent orchestration patterns
  Scenario: Lead applies the TDD pipeline pattern
    Given a feature request from a Project Lead
    When the controller runs the documented pipeline (idea-to-spec → prd-editor → tdd-tester → tdd-coder)
    Then each phase hands off via the documented JSON protocol
    And a blocked coder routes to tdd-debugger per the error-recovery section
    And the tasker auto-terminates after timeout_minutes if hung
  Scenario: Lead needs a parallel fan-out pattern
    When the lead looks up the parallel/conditional/feedback-loop pattern specs
    Then no formal specification or runnable example exists today (gap)
```
