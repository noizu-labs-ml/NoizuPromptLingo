# User Story: Expose Fabric Pattern Tools

**ID**: US-0103
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: Medium
**Status**: Draft
**PRD Group**: executor_exposure
**Created**: 2026-02-02

## As a...
DevOps engineer enabling workflow automation

## I want to...
Expose Fabric CLI pattern tools as MCP tools for reusable workflow execution

## So that...
Agents can apply atomic workflow patterns and analyze outputs using established best practices

## Acceptance Criteria
- [ ] `apply_fabric_pattern` MCP tool registered (execute Fabric pattern)
- [ ] `analyze_with_fabric` MCP tool registered (analyze using pattern)
- [ ] `list_fabric_patterns` MCP tool registered (discover available patterns)
- [ ] `store_tasker_context` MCP tool registered (preserve executor context)
- [ ] Pattern application working correctly with parameter binding
- [ ] Context preservation working (context persists across pattern executions)
- [ ] Test coverage 80%+ for all Fabric pattern operations
- [ ] Tool integration with fabric.py verified

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/10-external-executors.md`

**Tools to Expose**:

**1. list_fabric_patterns**
```
list_fabric_patterns(
  category: str = None    # Optional: filter by category (e.g., "analysis", "generation")
) -> list[dict]
Returns: [{id, name, category, description, parameters, requires_context}]
```

**2. apply_fabric_pattern**
```
apply_fabric_pattern(
  pattern_id: str,           # Pattern to apply
  input_data: str,           # Input for pattern processing
  executor_id: str = None,   # Optional: executor context
  parameters: dict = None    # Pattern-specific parameters
) -> dict
Returns: {
  pattern_id,
  status: "success",
  output: str,               # Pattern execution output
  context_preserved: bool,
  execution_time_ms: int
}
```

**3. analyze_with_fabric**
```
analyze_with_fabric(
  analyzer_pattern_id: str,  # Analysis pattern to use
  target_data: str,          # Data to analyze
  context_key: str = None    # Use executor context (from store_tasker_context)
) -> dict
Returns: {
  analyzer_pattern_id,
  status: "success",
  analysis: dict,            # Structured analysis results
  reasoning: str             # Human-readable interpretation
}
```

**4. store_tasker_context**
```
store_tasker_context(
  executor_id: str,          # Executor to save context from
  context_key: str,          # Key for later retrieval
  metadata: dict = None      # Optional metadata
) -> dict
Returns: {
  context_key,
  stored_at: datetime,
  executor_id,
  size_bytes: int,
  ttl_seconds: 3600
}
```

**Fabric Pattern System**:
- Fabric patterns are pre-built, tested CLI workflows from Fabric project
- Patterns are composable (can chain outputs to inputs)
- Pattern library includes analysis, generation, transformation patterns
- Context storage enables passing executor context between patterns

**Example Patterns** (typical Fabric categories):
- `summarize` - Summarize long text
- `extract_technical` - Extract technical details
- `explain_code` - Explain code in plain language
- `improve_writing` - Improve writing clarity
- `find_security_issues` - Analyze for security concerns
- `generate_documentation` - Generate docs from code
- `suggest_improvements` - Suggest refinements

**Implementation Location**:
- Core: `src/npl_mcp/executor/fabric.py` (already exists)
- Registration: `src/npl_mcp/unified.py` (needs MCP tool decorators)

**Database/Storage**:
- Pattern registry: Cached list of available patterns
- Context store: Key-value storage for executor context (TTL: 1 hour default)
- Execution log: Pattern execution history and outputs

**Operations**:

**list_fabric_patterns**:
- Query pattern registry
- Optional filtering by category
- Return metadata (id, name, description, parameters)

**apply_fabric_pattern**:
- Resolve pattern from registry
- Bind parameters (if provided)
- Load executor context (if executor_id provided)
- Execute Fabric pattern via subprocess/CLI
- Capture output and status
- Return results with timing

**analyze_with_fabric**:
- Select analysis pattern (e.g., "find_security_issues")
- Load context if context_key provided
- Execute pattern on target data
- Parse/structure output as analysis results
- Return interpretable analysis

**store_tasker_context**:
- Serialize executor context from memory
- Store in context_store with context_key
- Set TTL (default 1 hour) for automatic cleanup
- Return storage metadata

**Pattern Execution Flow**:
1. List available patterns
2. Select pattern matching task
3. Store executor context (if needed for future patterns)
4. Apply pattern with input data
5. Analyze results with optional secondary pattern
6. Use output for next task step

**Test Scenarios**:
- List all patterns (no filter)
- List by category filter
- Apply pattern with simple input
- Apply pattern with executor context
- Apply pattern with custom parameters
- Analyze data using analysis pattern
- Store and retrieve context
- Pattern execution error handling
- Invalid pattern ID (error)
- Context key not found (error)
- Pattern parameter validation
- Timeout handling for long-running patterns
- Concurrent pattern executions

**Context Storage**:
- Key: Human-readable string (e.g., "debug_context_2026-02-02")
- Value: Serialized executor state (JSON/pickle)
- TTL: Default 3600s, configurable
- Retrieval: By key (for analysis/apply_fabric_pattern)

## Related Stories
- US-101 (Expose Executor Spawn Tool)
- US-102 (Expose Executor Lifecycle Tools)
- US-100 (Add Executor System Test Suite)
- US-059 (Chain Multi-Agent Workflows with Dependencies)
- US-087 (Build NPL Syntax Pattern Library)

## Notes
Fabric patterns provide reusable workflow automation from established Fabric project. Implementation exists in fabric.py but not exposed as MCP tools. Context storage enables stateful workflows (spawn executor → run pattern → store context → later analysis). Pattern composition enables complex multi-step workflows. Context TTL important for memory management and cleanup.
