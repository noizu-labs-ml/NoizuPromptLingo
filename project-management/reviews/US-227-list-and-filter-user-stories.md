# Review: List and Filter User Stories

- **Story**: `project-management/user-stories/US-227-list-and-filter-user-stories.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

`list_stories` is implemented in `src/npl_mcp/pm_tools/stories.py:120-215` with all six filters (status, priority, persona, prd_group, prd) applied as combinable AND logic (`stories.py:156-181`), priority-then-ID sorting (`utils.py:369-391`), and offset/limit pagination with total/returned counts (`stories.py:184-213`). Summary objects omit full content as specified. Tests cover filtering, sorting, and pagination (`tests/test_pm_mcp_tools.py:745-881`, `TestListStories`). Like its sibling tools, it is catalog-listed but stub-only through ToolCall (`src/npl_mcp/meta_tools/stub_catalog.py:822-845`; `src/npl_mcp/launcher.py:434-438`), so it is not callable through the live MCP surface.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Returns all stories with no filters | Met | `src/npl_mcp/pm_tools/stories.py:154-181` (filters applied only when not None) |
| `status` filter | Met | `src/npl_mcp/pm_tools/stories.py:160-161` |
| `priority` filter | Met | `src/npl_mcp/pm_tools/stories.py:164-165` |
| `persona` filter by ID | Met | `src/npl_mcp/pm_tools/stories.py:168-169` |
| `prd_group` filter | Met | `src/npl_mcp/pm_tools/stories.py:172-173` |
| `prd` filter against linked PRDs array | Met | `src/npl_mcp/pm_tools/stories.py:176-179` (membership check in `prds`) |
| Summary data per story (id, title, status, priority, persona) | Met | `src/npl_mcp/pm_tools/stories.py:194-206` |
| Pagination with `limit` and `offset` | Met | `src/npl_mcp/pm_tools/stories.py:190-191`; negative offset clamped; total_count computed pre-pagination |
| Sorted by priority (critical first) then ID | Met | `src/npl_mcp/pm_tools/utils.py:361-391` (PRIORITY_ORDER map + numeric ID tiebreak) |

## Gaps / Risks

- **Exposure gap**: stub-only via ToolCall; not reachable from the live MCP server.
- No validation of filter values (e.g., `status=bogus` silently returns empty rather than erroring) — minor, unspecified.
- Sorting treats unknown priorities as "medium" (`utils.py:380`) — silently misorders malformed index entries.
- Open questions in the story (full-text search, OR logic, has_tests filter) are unimplemented — consistent with being open questions, not gaps.

## BDD Scenario

```gherkin
Feature: List and Filter User Stories

  Scenario: Agent finds high-priority draft stories for a PRD
    Given index.yaml contains stories with mixed statuses and priorities
    When the agent calls list_stories with status "draft", priority "high", and prd "PRD-005"
    Then only stories matching ALL three filters are returned
    And results are ordered critical-first then by numeric ID
    And each entry carries id, title, status, priority, persona summaries without content

  Scenario: Pagination
    Given 120 stories match the filter
    When the agent calls list_stories with limit 50 and offset 50
    Then returned_count is 50, total_count is 120, and offset is 50
```
