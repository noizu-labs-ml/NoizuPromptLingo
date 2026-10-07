# Review: Add Executor System Test Suite

- **Story**: `project-management/user-stories/US-100-add-executor-test-suite.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The executor system under test exists — `src/npl_mcp/executors/manager.py` (386 lines: spawn_tasker/get_tasker/list_taskers/touch/dismiss/keep_alive) and `src/npl_mcp/executors/fabric.py` (212 lines) — and is exposed as MCP tools (`Tasker.Spawn/Get/List/Touch/Dismiss/KeepAlive` and `Fabric.*`, `src/npl_mcp/launcher.py:1691-1841`). But no tests exist for any of it: grep across `tests/` for `executors`, `spawn_tasker`, `fabric`, or tasker-lifecycle functions returns nothing. The two test files with superficially related names (`tests/test_agents_tools.py`, `tests/test_agents_module.py`) test agent-definition-file parsing (frontmatter/kind classification), not executor lifecycle. No coverage measurement, no lifecycle/fabric/concurrency test categories, and no CI coverage gate exist for this story. (Note: the story's module path `src/npl_mcp/executor/manager.py` is singular; the actual path is `src/npl_mcp/executors/`.) Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Executor spawn and lifecycle management tested with 80%+ coverage | Not Met | Zero tests reference the executors package (`grep -rl "executors\|spawn_tasker" tests/` → nothing); no coverage tooling |
| Executor spawn tested (factory pattern, configuration) | Not Met | `spawn_tasker` (`src/npl_mcp/executors/manager.py`, wired at `src/npl_mcp/launcher.py:1697-1723`) untested |
| Lifecycle management tested (auto-spawn, idle timeout, cleanup) | Not Met | `dismiss_tasker`, `touch_tasker`, `keep_alive`, idle/timeout logic (`manager.py`) untested |
| Fabric pattern integration tested (pattern application, context preservation) | Not Met | `src/npl_mcp/executors/fabric.py` untested — `apply_fabric_pattern`, `analyze_with_patterns`, `list_patterns` have no test file |
| Context buffering tested (context injection, memory management) | Not Met | No context-buffer tests found |
| Background monitoring tested (health checks, timeout detection) | Not Met | No heartbeat/health-check tests found |
| Test suite passes in CI/CD with coverage report validation | Not Met | No executor test suite or coverage gate exists |

## Gaps / Risks

- The executors own real process lifecycle (subprocess spawn, IPC, idle-timeout termination) — exactly the code where untested race conditions and orphaned processes bite; zero coverage is the highest-risk test gap in this batch.
- Story references a `taskers` DB table (id, type, owner, context, status, heartbeat fields) — any test suite needs fixtures for it; the table's migration/schema state should be confirmed when the suite is written.
- `analyze_with_patterns` has a known latent issue (does not forward timeout/model, see US-095-fabric review) that a test suite would have caught — supporting evidence for this story's value.
- Story path drift: `src/npl_mcp/executor/` vs actual `src/npl_mcp/executors/`; also references US-090 twice under two different titles (US-101/102/103 dependencies).

## BDD Scenario

```gherkin
Feature: Executor system test suite

  Scenario: Coverage gate on the executors package
    Given the pytest suite runs in CI with coverage reporting
    When it executes against src/npl_mcp/executors/
    Then manager.py and fabric.py report >= 80% line coverage
    # Today: FAILS — no tests exist for the package at all.

  Scenario: Tasker lifecycle from spawn to dismissal
    When a tasker is spawned via Tasker.Spawn with timeout_minutes=15
    Then it is tracked by id and appears in Tasker.List
    And Tasker.Touch resets its idle timer
    And Tasker.Dismiss terminates it and cleans up its process
    # Today: UNTESTED — manager.py has no test coverage.

  Scenario: Idle-timeout reaping
    Given a tasker with no activity past its timeout threshold
    When the background monitor runs
    Then the tasker transitions to TERMINATED and its process is reaped
    Leaving no orphaned subprocess

  Scenario: Fabric pattern application with fallback
    Given fabric is not installed
    When a tasker spawns with patterns=["analyze_logs"]
    Then the fallback result (truncated raw content) is returned without raising
    # Today: UNTESTED — fabric.py has no test coverage.
```
