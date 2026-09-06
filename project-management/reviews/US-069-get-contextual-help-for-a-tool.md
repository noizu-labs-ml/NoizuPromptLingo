# Review: Get Contextual Help for a Tool

- **Story**: `project-management/user-stories/US-069-get-contextual-help-for-a-tool.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

ToolHelp exists on both stacks with different depth. The Python version (`src/npl_mcp/meta_tools/help.py:59-110`) is LLM-driven: it feeds the tool's catalog entry plus a task description to an LLM with verbosity levels (1=brief, 2=one example, 3=multiple examples/edge cases), cached per (tool, task, verbose); errors return a structured error status. The Elixir backend version (`backend/lib/noizu_prompt_lingua/tools/tool_help.ex:23-73`) is template-based (no LLM): purpose, category, parameter list, and task guidance, plus a no-tool recommendation mode via substring matching (`:75-105`). Missing on both: explicit sibling disambiguation (e.g. ToolSearch vs ToolSummary) and structured preconditions/prerequisites. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Valid tool name returns plain-language purpose, at least one example call, and pitfalls/preconditions | Partially Met | `src/npl_mcp/meta_tools/help.py:18-35` — verbose≥2 prompts for an example call; pitfalls/preconditions only appear if the LLM volunteers them (not guaranteed by the prompt); Elixir `tool_help.ex:50-63` gives purpose + params but its "example" is a generic `Call <name> with the appropriate parameters` line, not a concrete call |
| Confusable siblings explicitly distinguished | Not Met | neither implementation references sibling tools: Python prompt (`help.py:37-43`) has no disambiguation instruction; Elixir output is fixed-template text with no sibling section |
| Required prior steps stated (e.g. Session.Create before Session.Update) | Not Met | no prerequisite data model or prompt section in either implementation (`help.py:45-51` user message contains only tool + params + task; `tool_help.ex:50-63` likewise) |

## Gaps / Risks

- Elixir ToolHelp requires a `task` argument (`tool_help.ex:14-17` required field) — a newcomer calling "help for tool X" without a task gets a required-param error rather than help; story implies tool-only help.
- Python ToolHelp output quality depends on the LLM backend (`llm_client.chat_completion`); when it fails the caller gets `status: "error"` with no degraded static help (contrast with Elixir's always-available template).
- No tests found asserting example presence or pitfall coverage.

## BDD Scenario

```gherkin
Feature: Get contextual help for a tool

  Scenario: Newcomer asks how to use a tool
    Given a catalog tool "NPLSpec"
    When the user calls ToolHelp(tool="NPLSpec", task="generate a full NPL spec", verbose=3)
    Then the response includes the tool's purpose, parameter guidance, and at least one example call
    And the result is cached for the same (tool, task, verbose) triple

  Scenario: Unknown tool
    When ToolHelp is called with a tool name not in the catalog
    Then the response is a structured error ("Tool '<name>' not found in catalog."), not a crash

  Scenario: Confusable siblings and prerequisites (NOT YET GUARANTEED)
    When ToolHelp is called on ToolSearch
    Then no section explicitly contrasts ToolSearch with ToolSummary
    And no stated prerequisite such as "Session.Create must precede Session.Update" is returned
```
