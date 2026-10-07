# Review: Generate Coverage Reports for All Loaded Components

- **Story**: `project-management/user-stories/US-205-generate-coverage-reports.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

All five target modules exist (`src/npl_mcp/npl/parser.py`, `resolver.py`, `filters.py`, `layout.py`, `loader.py`), pytest-cov is a declared dependency (`pyproject.toml:20`), and the mise tasks `test-coverage` / `test-html` / `test-status` / `test-errors` are configured as the story specifies (with `--cov-report=term-missing --cov-report=html`). Measured coverage for the npl loading suite (`uv run pytest tests/test_npl_loading.py --cov=src/npl_mcp/npl`): 95 tests pass, overall 96% — parser 96%, resolver 98%, filters 94%, layout 97%, loader 92%, so the 80% floor (AC-5.1) is met. The 100% critical-path requirement (AC-5.3) is NOT met: uncovered lines are exactly critical error/boundary paths — `filters.py:48` (negative max_priority → return []), `parser.py:185,191,204` (empty-term, bare-dash subtraction, subtraction-only expression errors), `resolver.py:268-269` (fully-subtracted section fallback), `loader.py:99-101` (unexpected-error wrapping).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| AC-5.1: All new code >= 80% line coverage | Met | Measured 2026-09-06: npl modules 92-98% each, total 96% (pytest-cov run on tests/test_npl_loading.py) |
| AC-5.2: Coverage via `mise run test-coverage` | Met | `mise.toml` defines `test-coverage` with `--cov=src/npl_mcp --cov-report=term-missing --cov-report=html`; `pytest-cov>=5.0` in `pyproject.toml:20` |
| AC-5.3: Critical paths at 100% (parser, resolver, filter) | Not Met | Measured: parser 96% (lines 185,191,204), resolver 98% (lines 268-269), filters 94% (line 48) |
| AC-5.4: Report shows gaps and uncovered branches | Met | `term-missing` and `html` reports configured in mise.toml; missing lines identified per module (used for AC-5.3 evidence) |
| AC-5.5: No regression in existing test coverage | Partially Met | npl loading suite: 95/95 pass in 4.85s; full-suite regression and baseline comparison not verified in this review |

## Gaps / Risks

- `filters.py:48` uncovered means the negative-max_priority boundary — explicitly called out in the story as a critical priority boundary — has no test.
- Parser error branches (185/191/204) uncovered despite the story listing "critical error handling paths" in the validation checklist.
- Story's success metric "test execution time < 5 seconds" holds for the npl suite (4.85s) but was not measured for the full suite.
- Branch coverage (story requires >= 80% branch, not just line) was not measured in this review; pytest-cov config would need `--cov-branch`.

## BDD Scenario

```gherkin
Feature: Coverage reporting for NPL loading extension
  As a QA engineer
  I want measurable coverage for the extended loading functionality

  Scenario: Generate a coverage report
    When I run "mise run test-coverage"
    Then pytest executes the suite with coverage enabled
    And a term-missing table and htmlcov/ report are produced
    And the npl parser/resolver/filter/layout/loader modules each show > 80% line coverage

  Scenario: Identify critical-path gaps
    When I read the term-missing report
    Then uncovered lines are listed explicitly, including filters.py:48 and parser.py:185,191,204
    And the 100% critical-path target is shown as not yet met
```
