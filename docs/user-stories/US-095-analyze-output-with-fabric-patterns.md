# User Story: Analyze Output with Fabric Patterns

**ID**: US-095
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Documented
**Created**: 2026-02-02

## Story

As an **AI agent**,
I want to **analyze command output and content using Fabric CLI patterns**,
So that **I can extract insights, summarize logs, and explain code using LLM-based templates**.

## Acceptance Criteria

- [ ] Can apply single fabric pattern via `apply_fabric_pattern()`
- [ ] Can apply multiple patterns and combine results via `analyze_with_patterns()`
- [ ] Can list available patterns via `list_fabric_patterns()`
- [ ] Supports common patterns: summarize, extract_wisdom, analyze_logs, explain_code
- [ ] Gracefully falls back when fabric CLI not installed
- [ ] Supports timeout handling for long-running analysis
- [ ] Can specify custom model for analysis

## Implementation Status

✅ **Implemented in mcp-server worktree but NOT exposed as MCP tools**

### Potential MCP Tools (Not Exposed)

- `apply_fabric_pattern(content, pattern, model, timeout)` - Apply single pattern
- `analyze_with_fabric(content, patterns, combine_results)` - Apply multiple patterns
- `list_fabric_patterns()` - List available patterns

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/executors/fabric.py`
- **NOTE**: Tools NOT registered in `worktrees/main/mcp-server/src/npl_mcp/unified.py`

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/10-external-executors.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/executor-tools.yaml`

## Common Fabric Patterns

| Pattern | Use Case |
|---------|----------|
| `summarize` | General content summarization |
| `extract_wisdom` | Extract key insights and wisdom |
| `analyze_logs` | Analyze log output for errors and patterns |
| `explain_code` | Explain code snippets |
| `extract_main_idea` | Get core message from content |
| `analyze_claims` | Analyze and fact-check claims |
| `create_summary` | Create structured summary |

## Example Usage

```python
# Apply single pattern to test output
result = await apply_fabric_pattern(
    content=test_output,
    pattern="analyze_logs",
    timeout=300
)
# Returns: {"success": True, "result": "...", "pattern": "analyze_logs"}

# Apply multiple patterns with combined output
result = await analyze_with_fabric(
    content=docs_content,
    patterns=["extract_wisdom", "create_summary"],
    combine_results=True
)
# Returns markdown with sections for each pattern

# List available patterns
patterns = await list_fabric_patterns()
# Returns: {"patterns": [...], "count": N}
```

## Dependencies

- **External**: Fabric CLI (https://github.com/danielmiessler/fabric)
- **Installation**: `pip install fabric` or clone from GitHub

## Notes

- **CRITICAL**: Full implementation exists but MCP tools NOT exposed in `unified.py`
- Fabric patterns use LLM models (OpenAI, Anthropic, etc.) configured via fabric CLI
- Pattern selection heuristics map task types to optimal patterns
- Graceful fallback returns truncated raw content if fabric unavailable

## Related Stories

- US-048: Real-Time Agent Workflow Failure Diagnostics
- US-054: Test Execution Error Detail Capture
- US-094: Spawn Ephemeral Tasker Agents
