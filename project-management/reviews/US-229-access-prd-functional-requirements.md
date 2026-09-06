# Review: Access PRD Functional Requirements

- **Story**: `project-management/user-stories/US-229-access-prd-functional-requirements.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`get_prd_functional_requirement` is implemented in `src/npl_mcp/pm_tools/prds.py:190-346` with tests (`tests/test_pm_mcp_tools.py:999-1109`, `TestGetFunctionalRequirement`). It validates the PRD exists, handles a missing/absent supporting directory gracefully (empty list for `*`, NotFoundError for a specific ID — `prds.py:224-249`), loads FR data from `functional-requirements/index.yaml` with glob fallback that extracts IDs and titles from filenames/content (`prds.py:305-346`), supports `fr_id="*"` listing (default is `"*"` so omission works) and single-FR retrieval with full markdown content (`prds.py:254-302`). The relationship metadata the story requires — `acceptance_tests`, `depends_on`, `blocks` — is not implemented anywhere in the response. Stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:854-862`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_prd_functional_requirement(prd_id, fr_id)` accepts PRD and FR IDs | Met | `src/npl_mcp/pm_tools/prds.py:190-209` |
| Returns full markdown content of the FR file | Met | `src/npl_mcp/pm_tools/prds.py:287-292,301` |
| Returns FR metadata (id, title, status, priority) | Met | `src/npl_mcp/pm_tools/prds.py:294-302` (index-backed); glob fallback defaults status/priority (`:338-344`) |
| Returns related acceptance test IDs | Not Met | no evidence found — no `acceptance_tests` field in either response shape |
| Returns dependency information (depends_on, blocks) | Not Met | no evidence found |
| Lists all FRs when `fr_id` omitted or "*" | Met | default `fr_id="*"` (`prds.py:192`); list branch `:254-270` returns summaries + total_count |
| 404-style error if PRD or FR does not exist | Met | `prds.py:234-236,247-249,281-284` |
| FR IDs follow "FR-001" format | Met | `normalize_fr_id` at `src/npl_mcp/pm_tools/utils.py:103-122`; entry match at `prds.py:276-279` |

## Gaps / Risks

- **Exposure gap**: stub-only via ToolCall; unreachable from the live MCP server.
- `acceptance_tests`, `depends_on`, `blocks` relationship fields entirely absent — FR↔AT traceability (the story's stated purpose for targeted test generation) is not possible.
- Glob fallback (no index.yaml) fabricates `status: "documented"`, `priority: "medium"` defaults rather than deriving real metadata; list summaries also omit the story-specified `acceptance_test_count`.
- Bare `except:` around index load (`prds.py:319-323`) swallows malformed-YAML errors and silently falls back to glob.

## BDD Scenario

```gherkin
Feature: Access PRD Functional Requirements

  Scenario: Agent reads one FR for targeted test generation
    Given PRD-005 has a functional-requirements directory with index.yaml listing FR-003
    When the agent calls get_prd_functional_requirement with prd_id "PRD-005", fr_id "FR-003"
    Then the response includes fr_id "FR-003", title, status, priority, and the full markdown content
    But no acceptance_tests, depends_on, or blocks fields are returned

  Scenario: List all FRs
    When the agent calls get_prd_functional_requirement with prd_id "PRD-005" (fr_id omitted)
    Then all FRs are summarized with total_count
    And a PRD without a supporting directory returns total_count 0 instead of erroring
```
