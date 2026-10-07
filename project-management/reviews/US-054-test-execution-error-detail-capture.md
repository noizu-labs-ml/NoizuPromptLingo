# Review: Test Execution Error Detail Capture

- **Story**: `project-management/user-stories/US-054-test-execution-error-detail-capture.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Not implemented in the Python server repo. The mise task the story builds on exists but is print-only: `test-errors = "uv run pytest --tb=no -q tests/"` (`.mise.toml:30-31`) explicitly suppresses tracebacks and writes nothing anywhere. There is no `.npl/logs/test-failures.jsonl` anywhere in the repo, no JSONL capture of pytest failures, no structured failure records (test name / file / line / assertion / stack), no diff capture, no screenshot hook for browser tests, and no PRD/artifact linking or retention policy (the "last 50 runs per feature" store does not exist). Searches for `test-failures`, `jsonl`, and failure-capture hooks across the repo and mise tasks return nothing. The related US-051 worklog protocol review covers the same absent infrastructure from the agent-facing side.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `mise run test-errors` output captured to `.npl/logs/test-failures.jsonl` | Not Met | `.mise.toml:30-31` runs `pytest --tb=no -q` with no output capture; no `.npl/logs/test-failures.jsonl` exists |
| Each failure includes test name, file, line, assertion error, full stack | Not Met | no evidence found — the existing task even strips tracebacks (`--tb=no`) |
| Side-by-side diff for assertion failures | Not Met | no evidence found |
| Screenshots for browser-based test failures | Not Met | no evidence found |
| Automatic linking to related PRD and artifact | Not Met | no evidence found |
| Retention: last 50 test runs per feature | Not Met | no evidence found |

## Gaps / Risks

- The `mise run test-errors` task name suggests intent, but its current form (`--tb=no -q`) is the opposite of what the story needs — it would need to become a wrapper script (e.g. pytest with `--tb=long -rf` plus a JSON-report plugin writing the JSONL file).
- Downstream consumers already assume this exists: `npl-tdd-coder` and `npl-tdd-debugger` agent instructions reference `mise run test-status`/`test-failures` for feedback; neither task provides structured failure data today (see also US-051 worklog review — the worklog prerequisite is unbuilt across this story cluster).

## BDD Scenario

```gherkin
Feature: Automatic test failure diagnostics

  Scenario: A failing test run is captured
    Given the TDD workflow runs mise test tasks
    When a test fails
    Then the story expects a JSONL record with name/file/line/assertion/stack,
      an expected-vs-actual diff, screenshots for browser tests,
      PRD linkage, and 50-run retention per feature
    But the mise task prints a one-line summary and stores nothing,
      so this scenario cannot be executed
```
