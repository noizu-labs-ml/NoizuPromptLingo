# Review: Get a Tool's Full Definition

- **Story**: `project-management/user-stories/US-068-get-a-tools-full-definition.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

ToolDefinition is implemented in both codebases. The Elixir backend version (`backend/lib/noizu_prompt_lingua/tools/tool_definition.ex:19-52`) accepts one name or a comma-separated list, resolves dotted aliases (`Catalog.resolve_alias/1`), and returns full name/category/description/parameters per tool, collecting unknown names in a `not_found` list rather than erroring partially. The Python version (`src/npl_mcp/meta_tools/definition.py:8-38`) is equivalent. Parameters are derived from the tool's real input schema (`backend/.../tools/catalog.ex:208-235` `schema_to_params`; `src/npl_mcp/meta_tools/catalog.py:415-434` `_schema_to_params`), preserving types, required flags, and descriptions. Confidence: high. One depth caveat: nested object/array parameters are flattened to a top-level type token — see criterion 3.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Valid tool name returns full parameter schema (types, required/optional, descriptions) | Met | `backend/lib/noizu_prompt_lingua/tools/tool_definition.ex:34-43`; param extraction from the tool's JSON schema with per-param type/required/description at `backend/lib/noizu_prompt_lingua/tools/catalog.ex:210-233` |
| Nonexistent tool name returns a clear not-found indication, not a partial/empty schema | Met | `tool_definition.ex:30-32,48-51` — missing names go to `not_found` list; Python `src/npl_mcp/meta_tools/definition.py:32-37` same (ToolSummary's `#Tool` lookup also errors clearly, `tool_summary.ex:88-90`) |
| Nested object/array parameters fully expanded, not summarized or truncated | Partially Met | `backend/.../tools/catalog.ex:228` and `src/npl_mcp/meta_tools/catalog.py:425` collapse nested values to a flat type token (`object`→`str`-mapped/"dict"); inner properties/arrays are not recursed into |

## Gaps / Risks

- Nested schemas: a tool taking `options: object` shows only `type: dict` — an agent constructing a ToolCall for such a tool cannot learn inner field names/types from ToolDefinition alone (must call the tool or read source). This is the main story-fidelity gap.
- Not-found is a list entry (`not_found`) rather than an error — matches the story's intent ("clear not-found error rather than partial schema") but callers must check the field.

## BDD Scenario

```gherkin
Feature: Get a tool's full definition

  Scenario: Agent fetches a schema before ToolCall
    Given a tool listed by ToolSummary
    When the agent calls ToolDefinition(tool="<name>")
    Then the response includes the tool's name, category, description, and full parameter list
    And each parameter carries its type, required flag, and description

  Scenario: Unknown tool and nested parameters
    When ToolDefinition is called with a name not on the server
    Then the name is returned under not_found with no fabricated schema
    When the tool has a nested object parameter
    Then the parameter is listed with a generic object/array type token, without its inner properties (known limitation)
```
