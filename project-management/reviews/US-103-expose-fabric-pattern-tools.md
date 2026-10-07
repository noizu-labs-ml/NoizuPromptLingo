# Review: Expose Fabric Pattern Tools

- **Story**: `project-management/user-stories/US-103-expose-fabric-pattern-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Three of the four requested tools are registered as MCP tools in `src/npl_mcp/launcher.py:1795-1841` (`Fabric.Apply`, `Fabric.Analyze`, `Fabric.ListPatterns`), backed by `src/npl_mcp/executors/fabric.py`: `apply_fabric_pattern` (:39) shells out to the fabric CLI with model/timeout options and structured success/error/timeout results including a truncated-content fallback; `analyze_with_patterns` (:103) chains multiple patterns with optional result combination; `list_patterns` (:151) queries `fabric --listpatterns` with a built-in fallback catalog (:9-17). The fourth tool, `store_tasker_context`, is NOT MCP-exposed — `store_context`/`get_context` exist in `src/npl_mcp/executors/manager.py:184-223` but are in-memory only, capped at 10 history entries, with no TTL, no `context_key` retrieval by key, and no tool registration. Parameter binding, executor-context injection into pattern execution, and pattern-parameter validation from the story are absent (tool signatures take raw `content`/`pattern`, not `input_data`/`parameters`/`executor_id`/`context_key`). No tests exist for fabric operations. Tool integration with `fabric.py` is verified by direct delegation in `launcher.py`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `apply_fabric_pattern` MCP tool registered | Met (renamed `Fabric.Apply`) | `launcher.py:1795-1812` → `fabric.py:39-100`; executes pattern via fabric CLI subprocess |
| `analyze_with_fabric` MCP tool registered | Met (variant) | `launcher.py:1814-1830` `Fabric.Analyze` → `fabric.py:103-148`; applies multiple patterns (story's version uses one analyzer + context_key) |
| `list_fabric_patterns` MCP tool registered | Met (renamed `Fabric.ListPatterns`) | `launcher.py:1832-1841` → `fabric.py:151-193`; live CLI listing with static fallback |
| `store_tasker_context` MCP tool registered | Not Met | No MCP registration; internal `manager.py:184-209` only, in-memory, no TTL, no key-based retrieval |
| Pattern application working correctly with parameter binding | Partially Met | Pattern execution works (`fabric.py:55-85`) but there is no parameter binding — only optional `model`/`timeout` |
| Context preservation working (persists across pattern executions) | Partially Met | `manager.py:184-223` preserves tasker command history in memory; not accessible to fabric tools, no TTL-based store |
| Test coverage 80%+ for all Fabric pattern operations | Not Met | No fabric tests in `tests/` |
| Tool integration with fabric.py verified | Met (code-level) | All three launcher tools delegate to `fabric.py` functions; untested at runtime |

## Gaps / Risks

- Graceful degradation when fabric CLI is missing returns `"success": False` with truncated input as `result` and `fallback: True` — callers must check the flag or mistake raw input for pattern output.
- Pattern name is passed unsanitized to `create_subprocess_exec` argv (`fabric.py:55`) — safe from shell injection (no shell), but an invalid pattern only fails at runtime with stderr.
- The stateful "spawn executor → run pattern → store context → later analysis" workflow the story describes cannot be assembled today: the context store is not keyed or exposed.
- Error taxonomy mixes transport errors (timeout) and pattern errors under the same shape.

## BDD Scenario

```gherkin
Feature: Apply Fabric patterns as MCP tools

  Scenario: Agent lists available patterns
    Given the fabric CLI is installed on the host
    When an agent calls Fabric.ListPatterns
    Then the tool returns the CLI's pattern list and count
    But if the CLI is absent, it returns the built-in fallback catalog with success=false

  Scenario: Agent applies a pattern to content
    When an agent calls Fabric.Apply with content and pattern "summarize"
    Then the tool pipes the content to the fabric CLI
    And returns the pattern output with success=true

  Scenario: Pattern execution times out
    Given a pattern that exceeds the 300s timeout
    When Fabric.Apply is called
    Then the tool returns success=false with a timeout error and truncated input as fallback

  Scenario: Store executor context for later analysis (NOT yet possible)
    When an agent wants to save a tasker's context under a reusable key
    Then no MCP tool exists to do so; the internal store is in-memory and key-less
```
