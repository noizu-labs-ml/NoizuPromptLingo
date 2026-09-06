# Review: Analyze Output with Fabric Patterns

- **Story**: `project-management/user-stories/US-095-analyze-output-with-fabric-patterns.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Full implementation exists and — contrary to the story's "NOT exposed as MCP tools" note — all three tools ARE now registered as MCP tools: `Fabric.Apply`, `Fabric.Analyze`, `Fabric.ListPatterns` (`src/npl_mcp/launcher.py:1795-1841`, category "Executors"). The story's cited source paths (`worktrees/main/mcp-server/...`) are stale; the actual implementation lives at `src/npl_mcp/executors/fabric.py` (212 lines). The module implements single-pattern application with timeout and custom model, multi-pattern combination into sections, pattern listing via `fabric --listpatterns`, a static pattern catalog for common patterns, and graceful fallback (truncated raw content) when the CLI is missing, fails, or times out. Confidence: high. Minor gap: `analyze_with_patterns` does not forward `timeout`/`model` to per-pattern calls (`src/npl_mcp/executors/fabric.py:120`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Apply single fabric pattern via `apply_fabric_pattern()` | Met | `src/npl_mcp/executors/fabric.py:39-100`; exposed as `Fabric.Apply` `src/npl_mcp/launcher.py:1795-1812` |
| Apply multiple patterns and combine via `analyze_with_patterns()` | Met | `src/npl_mcp/executors/fabric.py:103-148` (per-pattern sections joined with `---` separators); `Fabric.Analyze` `src/npl_mcp/launcher.py:1814-1830` |
| List available patterns via `list_fabric_patterns()` | Met | `src/npl_mcp/executors/fabric.py:151-193` (`list_patterns`, `--listpatterns`); `Fabric.ListPatterns` `src/npl_mcp/launcher.py:1832-1841` |
| Supports common patterns (summarize, extract_wisdom, analyze_logs, explain_code) | Met | `FABRIC_PATTERNS` catalog `src/npl_mcp/executors/fabric.py:9-17`; task-type heuristic `:196-212` |
| Graceful fallback when fabric CLI not installed | Met | `src/npl_mcp/executors/fabric.py:46-53` (truncated content + `fallback: true`); also on nonzero exit `:72-78` |
| Timeout handling for long-running analysis | Met | `asyncio.wait_for(..., timeout=timeout)` `src/npl_mcp/executors/fabric.py:67-70`, timeout result `:87-93` |
| Can specify custom model | Met | `--model` flag `src/npl_mcp/executors/fabric.py:56-57`; `model` param on `Fabric.Apply` `src/npl_mcp/launcher.py:1804` |

## Gaps / Risks

- `analyze_with_patterns` (`src/npl_mcp/executors/fabric.py:120`) calls `apply_fabric_pattern(content, pattern)` without forwarding `timeout` or `model` — multi-pattern runs use the 300s default and no model override; each pattern also runs sequentially.
- No unit tests found for `src/npl_mcp/executors/fabric.py` or the Fabric tools (`grep -rl executors/fabric tests/` returns nothing).
- `find_fabric()` probes hardcoded paths plus `PATH`; no config override.
- Story doc drift: status section claims tools are not exposed and cites non-existent `worktrees/main/mcp-server/` paths — should be updated.

## BDD Scenario

```gherkin
Feature: Analyze output with Fabric patterns

  Scenario: Agent summarizes test logs with a single pattern
    Given the fabric CLI is installed at a discoverable location
    When the agent calls Fabric.Apply with content="<build log>", pattern="analyze_logs", timeout=120
    Then the response contains success=true and the pattern's LLM analysis in "result"
    # Fallback path:
    # Given fabric is not installed
    # When the agent calls Fabric.Apply
    # Then the response has success=false, fallback=true, and the first 1000 chars of the raw content

  Scenario: Agent applies multiple patterns and gets a combined report
    When the agent calls Fabric.Analyze with content="<doc>", patterns=["extract_wisdom", "create_summary"]
    Then "result" contains a "## extract_wisdom" section and a "## create_summary" section
    And "individual_results" holds each pattern's individual outcome

  Scenario: Agent discovers available patterns
    When the agent calls Fabric.ListPatterns
    Then the response lists installed fabric pattern names with a count
    # Given fabric is missing
    # Then the response includes the built-in common_patterns catalog with success=false
```
