# Review: List All Tools on an MCP Server

- **Story**: `project-management/user-stories/US-065-list-all-tools-on-an-mcp-server.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements ToolSummary as a Discovery-category MCP tool on every domain server (`backend/lib/noizu_prompt_lingua/tools/tool_summary.ex`; registered per-server, e.g. `backend/lib/noizu_prompt_lingua/domains/unicode_codex/mcp.ex:22`). It returns all non-Discovery tools grouped by category with name + one-line description, with no pagination or truncation path. The catalog is rebuilt per call from the server's registered tool specs (`backend/lib/noizu_prompt_lingua/tools/catalog.ex:31-53` — `build/2` calls `server.__mcp__(:tools)` fresh each invocation), so newly registered tools appear without reconnect. A parallel Python implementation exists at `src/npl_mcp/meta_tools/summary.py:14-69` (uses a cached catalog with explicit `invalidate_catalog`). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| ToolSummary with no args lists every tool with name and one-line description | Met | `backend/lib/noizu_prompt_lingua/tools/tool_summary.ex:51-75` (`all_tools/3` groups by category, each entry `{name, description}`); note: the "Discovery" category itself is excluded by design (line 53) |
| 20+ tools return in a single call without pagination or silent truncation | Met | `tool_summary.ex:51-75` — no limit/pagination logic; full list returned in one response |
| Newly registered tool appears without reconnect/restart | Met | `backend/lib/noizu_prompt_lingua/tools/catalog.ex:31-53` — catalog built per call from live server specs; no persistent cache on the Elixir path (Python path: `src/npl_mcp/meta_tools/catalog.py:442,527` cache + `invalidate_catalog`) |

## Gaps / Risks

- The default listing excludes Discovery tools (ToolSummary, ToolSearch, …) — callers must know to use ToolSearch/ToolHelp to surface them; story text says "every tool it exposes", which is technically not satisfied for the Discovery five.
- No tests found asserting the 20+-tool single-call behavior specifically.

## BDD Scenario

```gherkin
Feature: List all tools on an MCP server

  Scenario: Agent orients on a server before deep calls
    Given an MCP client connected to the tobor_unicode server
    When the client calls ToolSummary with no arguments
    Then the response contains total_tools and categories with every non-Discovery tool listed by name and description
    And the response includes a hint pointing to ToolSummary(filter=...) and ToolDefinition

  Scenario: Newly registered tool appears
    Given a server that has just registered a new tool in its MCP module
    When a connected client calls ToolSummary again (same session)
    Then the new tool appears in the category listing without the client reconnecting
```
