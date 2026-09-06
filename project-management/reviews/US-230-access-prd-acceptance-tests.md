# Review: Access PRD Acceptance Tests

- **Story**: `project-management/user-stories/US-230-access-prd-acceptance-tests.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`get_prd_acceptance_test` is implemented in `src/npl_mcp/pm_tools/prds.py:349-528` with tests (`tests/test_pm_mcp_tools.py:1111-1239`, `TestGetAcceptanceTest`). It supports single-AT retrieval with full markdown plus structured `preconditions`/`steps`/`expected_results` parsed via section extraction (`prds.py:466-468`, `utils.py:222-254`), listing with coverage statistics (`implemented_count`, `coverage_percentage` — `prds.py:412-441`), FR-scoped filtering via the `fr_id` parameter (`prds.py:408-410`), graceful empty-directory handling (`prds.py:388-402`), and 404 errors for missing PRD/AT. Weak points: `normalize_at_id` only handles `AT-XXX`, not the story's `AT-XXX-YYY` sub-numbered form; the glob fallback never extracts `fr_id` from `AT-XXX-YYY` filenames, so index-less PRDs lose FR linkage; and ID formats like "AT-003-001" pass through unnormalized. Stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:863-872`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_prd_acceptance_test(prd_id, at_id)` accepts PRD and AT IDs | Met | `src/npl_mcp/pm_tools/prds.py:349-375` |
| Returns full markdown content of the AT file | Met | `src/npl_mcp/pm_tools/prds.py:457-463,479` |
| Returns AT metadata (id, title, status, test_type) | Met | `src/npl_mcp/pm_tools/prds.py:470-478`; index-backed; glob fallback defaults (`:519-526`) |
| Returns the FR this AT verifies | Partially Met | `fr_id` returned from index data (`prds.py:475`); glob fallback never extracts FR from "AT-XXX-YYY" filenames (`_load_at_data`, `:507-526`) so linkage is lost without index.yaml |
| Returns preconditions, steps, expected results as structured data | Met | `src/npl_mcp/pm_tools/prds.py:466-468,480-482`; parser at `utils.py:222-254` |
| Lists all ATs when `at_id` omitted or "*" | Met | default `at_id="*"` (`prds.py:351`); list branch with coverage stats `:412-441` |
| Lists all ATs for a specific FR with `fr_id` | Met | `src/npl_mcp/pm_tools/prds.py:408-410` (filter applied before both branches) |
| 404-style error if PRD or AT does not exist | Met | `prds.py:400-402,452-455` |
| AT IDs follow "AT-XXX-YYY" format | Partially Met | `normalize_at_id` matches only `AT-\d+` (`utils.py:125-144`); "AT-003-001" is returned unnormalized and glob discovery keys entries by the "AT-003" prefix only (`prds.py:511`), so sub-numbered IDs are unreliable |

## Gaps / Risks

- **Exposure gap**: stub-only via ToolCall; unreachable from the live MCP server.
- `AT-XXX-YYY` sub-numbering (the story's stated ID scheme) is not modeled — two tests under the same FR cannot be addressed distinctly via glob discovery.
- `implementation_status` is index-supplied only; glob fallback hardcodes `not_implemented`, skewing coverage_percentage.
- Bare `except:` on index load (`prds.py:499-504`) silently masks malformed YAML.

## BDD Scenario

```gherkin
Feature: Access PRD Acceptance Tests

  Scenario: TDD agent pulls one AT to generate test code
    Given PRD-005 has an acceptance-tests directory with index.yaml entry AT-003
    When the agent calls get_prd_acceptance_test with prd_id "PRD-005", at_id "AT-003"
    Then the response includes title, fr_id, status, test_type, implementation_status, and full content
    And preconditions, steps, and expected_results are structured lists parsed from the markdown

  Scenario: Coverage rollup for an FR
    When the agent calls get_prd_acceptance_test with prd_id "PRD-005", fr_id "FR-003", at_id "*"
    Then only ATs whose fr_id is FR-003 are listed
    And total_count, implemented_count, and coverage_percentage are computed over that subset
```
