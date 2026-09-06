# Review: Read PRD Content by ID

- **Story**: `project-management/user-stories/US-228-read-prd-content-by-id.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`get_prd` is implemented in `src/npl_mcp/pm_tools/prds.py:114-187` with tests (`tests/test_pm_mcp_tools.py:883-997`, `TestGetPRD`). It normalizes numeric/prefixed IDs (`src/npl_mcp/pm_tools/utils.py:72-100`), glob-discovers the PRD file (`prds.py:32-55`), returns full markdown content, extracts title/status/version from the markdown (`utils.py:289-326`), extracts US-XXX story references by regex (`utils.py:329-340`), and reports the supporting directory plus FR/AT presence and counts (`prds.py:148-183`). Two substantive spec misses: metadata is parsed from the markdown rather than from `index.yaml` (so `categories`, `tools`, `database_tables`, `web_routes` are absent entirely), and there is no MCP-tools/DB-tables/routes listing. The tool is also stub-only via ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:846-853`; `src/npl_mcp/launcher.py:434-438`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_prd(prd_id)` accepts "PRD-XXX" format | Met | `src/npl_mcp/pm_tools/prds.py:128-139` |
| Returns full markdown content of main PRD file | Met | `src/npl_mcp/pm_tools/prds.py:142,178` |
| Returns structured metadata from index.yaml (title, status, version, categories) | Partially Met | title/status/version parsed from markdown, not index.yaml (`src/npl_mcp/pm_tools/utils.py:289-326`); `categories` never returned |
| Returns list of associated user stories | Met | `src/npl_mcp/pm_tools/prds.py:170,184` (regex-extracted from content, `utils.py:329-340`) |
| Returns list of MCP tools defined in the PRD | Not Met | no evidence found — no `tools` field in the result object (`prds.py:172-185`) |
| Returns list of database tables and web routes | Not Met | no evidence found — no `database_tables`/`web_routes` fields |
| Returns paths to functional requirements and acceptance test directories | Partially Met | returns `supporting_directory` name plus `has_functional_requirements`/`has_acceptance_tests` and counts (`prds.py:179-183`); not explicit directory paths |
| Returns 404-style error if PRD ID does not exist | Met | `NotFoundError` at `src/npl_mcp/pm_tools/prds.py:138-139` |
| Handles numeric ("005") and prefixed ("PRD-005") IDs | Met | `src/npl_mcp/pm_tools/utils.py:90-97` |

## Gaps / Risks

- **Exposure gap**: stub-only via ToolCall; unreachable through the live MCP server.
- Metadata sourced from markdown, not the PRD index — PRDs whose index.yaml carries richer data (categories, tools, coverage) lose that data.
- No `tools`/`database_tables`/`web_routes` extraction; the story's output schema is only ~60% realized.
- `extract_prd_metadata` scans every line for `**Version**`/`**Status**` — a body mention overrides the header value (last match wins).

## BDD Scenario

```gherkin
Feature: Read PRD Content by ID

  Scenario: TDD agent loads a PRD for test scoping
    Given the file "PRD-005-task-queue-system.md" exists under project-management/PRDs/
    When the agent calls get_prd with prd_id "005"
    Then the response contains the full markdown content
    And title, status, and version are parsed from the document
    And user_stories lists every US-XXX reference found in the content
    And functional_requirements_count and acceptance_tests_count reflect the supporting directory

  Scenario: PRD not found
    When the agent calls get_prd with prd_id "PRD-9999"
    Then a NotFoundError-style result is returned
```
