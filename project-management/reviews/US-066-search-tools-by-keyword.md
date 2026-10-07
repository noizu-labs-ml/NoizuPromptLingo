# Review: Search Tools by Keyword

- **Story**: `project-management/user-stories/US-066-search-tools-by-keyword.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

ToolSearch mode=text is implemented in both codebases with identical semantics: case-insensitive substring matching over tool name and description, ranked exact-name → substring-name → description, capped at `limit`, returning a plain empty result set on no match. Elixir: `backend/lib/noizu_prompt_lingua/tools/tool_search.ex:46-76` (registered per-server in every domain's MCP module, e.g. `domains/unicode_codex/mcp.ex:23`). Python: `src/npl_mcp/meta_tools/search.py:45-72`. Both read from the per-call/per-server catalog, so results are naturally scoped to the target server. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Substring match on name/description returns only matching tools, exact name matches ranked first | Met | `backend/lib/noizu_prompt_lingua/tools/tool_search.ex:51-65` — three buckets concatenated `exact ++ name_match ++ desc_match`, then `Enum.take(all, limit)`; same logic at `src/npl_mcp/meta_tools/search.py:50-65` |
| Keyword matching nothing returns empty result set, not an error | Met | `tool_search.ex:67-75` — returns `%{total_matches: 0, matches: []}` (no error tuple); `search.py:67-72` same |
| Mixed-case keyword matches case-insensitively | Met | `tool_search.ex:49,53-54` — query and both fields `String.downcase/1` before comparison; `search.py:48,55-56` same |

## Gaps / Risks

- Ranking is bucketed (exact/substring/description) but within a bucket order is catalog order, not relevance-weighted — acceptable for the story as written.
- Python path has an internal catalog cache (`src/npl_mcp/meta_tools/catalog.py`) — stale results possible until `invalidate_catalog()`; Elixir path rebuilds per call.
- No dedicated tests found for the empty-result criterion in either repo's test dirs.

## BDD Scenario

```gherkin
Feature: Search tools by keyword

  Scenario: Operator finds a tool by substring
    Given a server exposing more than 20 tools including one named "ToolDefinition"
    When the client calls ToolSearch(query="definition", mode="text")
    Then only tools whose name or description contains "definition" are returned
    And an exact name match, if any, is listed before substring and description matches

  Scenario: No match and case-insensitivity
    When the client calls ToolSearch(query="zzzznomatch") with mixed case "ZzZzNoMatch"
    Then the response reports total_matches 0 with an empty matches list, not an error
    And lowercasing the query yields the same result set
```
