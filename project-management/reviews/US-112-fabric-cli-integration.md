# Review: Fabric CLI Integration

- **Story**: `project-management/user-stories/US-112-fabric-cli-integration.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Fully implemented in `src/npl_mcp/executors/fabric.py`. `find_fabric()` (fabric.py:20-36) auto-detects the binary across common install paths plus `shutil.which`. `apply_fabric_pattern` (fabric.py:39-100) pipes content via stdin with model/timeout support and handles non-zero exit, timeout, and general exceptions by returning a `fallback: True` envelope with truncated original content — graceful fallback when fabric is absent. `analyze_with_patterns` (fabric.py:103-148) applies multiple patterns and combines results. Pattern-selection heuristics map task types to patterns (fabric.py:196-212). The story's four common patterns (summarize, extract_wisdom, analyze_logs, explain_code) are all in the static `FABRIC_PATTERNS` list (fabric.py:9-17) plus three extras. No unit tests exist for the module (tests/ contains no fabric coverage), which is the only notable gap.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Auto-detect fabric installation | Met | `src/npl_mcp/executors/fabric.py:20-36` — ~/.local/bin, /usr/local/bin, /usr/bin, then PATH lookup |
| Apply single or multiple patterns to content | Met | `apply_fabric_pattern` fabric.py:39-100; `analyze_with_patterns` fabric.py:103-148 with combined output |
| Pattern selection heuristics for common tasks | Met | `select_pattern_for_task` fabric.py:196-212 — maps test/build output, logs, web content, docs, code, etc. |
| Graceful fallback when fabric unavailable | Met | fabric.py:47-53 returns `{"success": False, "fallback": True}` with truncated content; same shape on timeout (fabric.py:87-93) and error (fabric.py:94-100) |
| Support common patterns: summarize, extract_wisdom, analyze_logs, explain_code | Met | `FABRIC_PATTERNS` fabric.py:9-17 lists all four plus extract_main_idea, analyze_claims, create_summary |

## Gaps / Risks

- No tests: `tests/` has zero fabric-related test coverage (only substring matches in unrelated agent-name fixtures).
- `select_pattern_for_task` exists but is not wired into any MCP tool call path — callers must choose patterns themselves; the heuristic is only reachable if a tool caller invokes it directly.
- `list_patterns` shells out with `--listpatterns` and a 30s timeout but its output is not cached; repeated calls re-spawn the process.
- Fallback truncates content at 1000/2000 chars, which may silently drop the tail of large outputs.

## BDD Scenario

```gherkin
Feature: Fabric CLI integration for output analysis

  Scenario: Apply a pattern when fabric is installed
    Given fabric is installed at ~/.local/bin/fabric
    When the agent calls ToolCall("Fabric.Apply", {"content": "<build log>", "pattern": "analyze_logs"})
    Then the module spawns `fabric --pattern analyze_logs` with the content on stdin
    And returns {"success": true, "result": "<fabric analysis>"}

  Scenario: Apply multiple patterns and combine
    When the agent calls ToolCall("Fabric.Analyze", {"content": "<article>", "patterns": ["summarize", "extract_wisdom"]})
    Then each pattern runs in turn
    And the results are combined into one markdown body with "## <pattern>" sections

  Scenario: Fabric is not installed
    Given no fabric binary exists on PATH or common locations
    When the agent calls ToolCall("Fabric.Apply", {"content": "...", "pattern": "summarize"})
    Then the response has success=false, fallback=true, and an install hint
    And the first 1000 characters of the original content are returned unchanged
```
