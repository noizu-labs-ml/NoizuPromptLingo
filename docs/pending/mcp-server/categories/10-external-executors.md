# Category: External Executors

**Category ID**: C-10
**Tool Count**: 0 (MCP tools) / 2 (Implementation modules)
**Status**: Implemented but Not Exposed via MCP
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The External Executors category provides infrastructure for ephemeral tasker agents that can be spawned dynamically to handle specific tasks with automatic lifecycle management. This system integrates with the Fabric CLI tool for intelligent output analysis using LLM-based patterns.

The implementation is **complete** but MCP tools are **not yet exposed** to Claude Code. The infrastructure exists at `src/npl_mcp/executors/` with full lifecycle management, fabric integration, and chat-based notifications.

## Features Implemented

### Feature 1: Ephemeral Tasker Lifecycle Management
**Description**: Manages short-lived executor agents that automatically terminate after timeouts or completion.

**Core Capabilities**:
- Generate unique tasker IDs (`tsk-xxxxxxxx`)
- Track tasker lifecycle states: IDLE, ACTIVE, NAGGING, TERMINATED
- Auto-terminate after configurable timeout (default: 15 minutes)
- Send "nag" messages via chat after idle period (default: 5 minutes)
- Context buffering for follow-up queries
- In-memory state cache with persistent DB storage

**Database Tables**:
- `taskers` - Tasker registry with state, timeouts, patterns

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/executors/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: Not verified

**Test Coverage**: Unknown (not documented in PROJECT_STATUS.md)

**Key Classes**:
```python
class TaskerStatus(Enum):
    ACTIVE = "active"
    IDLE = "idle"
    NAGGING = "nagging"
    TERMINATED = "terminated"

class TaskerManager:
    - spawn_tasker(task, chat_room_id, patterns, session_id, timeout, nag_minutes)
    - get_tasker(tasker_id)
    - list_taskers(status, session_id)
    - touch_tasker(tasker_id)  # Reset activity timestamp
    - store_context(tasker_id, command, raw_output, analysis, result)
    - get_context(tasker_id)  # Retrieve for follow-up queries
    - dismiss_tasker(tasker_id, reason)
    - keep_alive(tasker_id)  # Respond to nag
    - start_lifecycle_monitor()  # Background monitoring task
    - stop_lifecycle_monitor()
```

**Lifecycle Flow**:
1. **Spawn**: Create tasker with task description, patterns, chat room
2. **Active**: Tasker executes commands, updates last_activity
3. **Idle**: No activity for `nag_minutes` → send nag message
4. **Nagging**: Parent has 2 minutes to respond with `keep_alive`
5. **Terminated**: Auto-dismiss after timeout or explicit dismissal

**Example Usage**:
```python
# Spawn tasker
tasker = await tasker_manager.spawn_tasker(
    task="Analyze test failures in auth module",
    chat_room_id=42,
    parent_agent_id="primary",
    patterns=["analyze_logs", "extract_wisdom"],
    timeout_minutes=15,
    nag_minutes=5
)
# Returns: {"tasker_id": "tsk-a3f7k2m9", "status": "idle", ...}

# Keep alive after nag
await tasker_manager.keep_alive("tsk-a3f7k2m9")

# Dismiss when done
await tasker_manager.dismiss_tasker("tsk-a3f7k2m9", reason="task_complete")
```

### Feature 2: Fabric CLI Integration
**Description**: Integrates with danielmiessler/fabric for intelligent LLM-based output analysis using pattern templates.

**Core Capabilities**:
- Auto-detect fabric CLI installation
- Apply single or multiple fabric patterns to content
- Pattern selection based on task type heuristics
- Graceful fallback when fabric not available
- Timeout handling for long-running analysis
- Pattern listing and discovery

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/executors/fabric.py`
- Tests: Not verified

**Test Coverage**: Unknown

**Common Patterns**:
| Pattern | Use Case |
|---------|----------|
| `summarize` | General content summarization |
| `extract_wisdom` | Extract key insights and wisdom |
| `analyze_logs` | Analyze log output for errors and patterns |
| `explain_code` | Explain code snippets |
| `extract_main_idea` | Get core message from content |
| `analyze_claims` | Analyze and fact-check claims |
| `create_summary` | Create structured summary |

**Key Functions**:
```python
# Find fabric CLI
find_fabric() -> Optional[Path]

# Apply single pattern
await apply_fabric_pattern(
    content: str,
    pattern: str,
    model: Optional[str] = None,
    timeout: int = 300
) -> Dict[str, Any]

# Apply multiple patterns
await analyze_with_patterns(
    content: str,
    patterns: List[str],
    combine_results: bool = True
) -> Dict[str, Any]

# List available patterns
await list_patterns() -> Dict[str, Any]

# Auto-select pattern for task type
select_pattern_for_task(task_type: str) -> str
```

**Pattern Selection Heuristics**:
```python
task_type_map = {
    "test_output": "analyze_logs",
    "build_output": "analyze_logs",
    "log_file": "analyze_logs",
    "web_content": "summarize",
    "documentation": "extract_wisdom",
    "code": "explain_code",
    "default": "summarize"
}
```

**Example Usage**:
```python
# Apply single pattern
result = await apply_fabric_pattern(
    content=test_output,
    pattern="analyze_logs",
    timeout=300
)
# Returns: {"success": True, "result": "...", "pattern": "analyze_logs"}

# Apply multiple patterns with combined output
result = await analyze_with_patterns(
    content=docs_content,
    patterns=["extract_wisdom", "create_summary"],
    combine_results=True
)
# Returns markdown with sections for each pattern
```

## MCP Tools Reference

**⚠️ IMPORTANT**: This category has **NO exposed MCP tools** despite having complete implementation.

### Potential Tools (Not Yet Implemented)

The following tools **should exist** but are not currently registered in `unified.py`:

```python
# Tasker lifecycle
spawn_tasker(task, chat_room_id, parent_agent_id, patterns, session_id, timeout_minutes, nag_minutes)
get_tasker(tasker_id)
list_taskers(status, session_id)
dismiss_tasker(tasker_id, reason)
keep_alive_tasker(tasker_id)

# Fabric integration
apply_fabric_pattern(content, pattern, model, timeout)
analyze_with_fabric(content, patterns, combine_results)
list_fabric_patterns()
```

## Database Model

### Tables

**taskers**:
```sql
CREATE TABLE IF NOT EXISTS taskers (
    id TEXT PRIMARY KEY,
    parent_agent_id TEXT NOT NULL,
    session_id TEXT,
    chat_room_id INTEGER NOT NULL,
    task TEXT NOT NULL,
    patterns TEXT,  -- JSON array of fabric patterns
    status TEXT NOT NULL,
    timeout_minutes INTEGER DEFAULT 15,
    nag_minutes INTEGER DEFAULT 5,
    created_at TEXT NOT NULL,
    last_activity TEXT NOT NULL,
    terminated_at TEXT,
    termination_reason TEXT
);
```

**Fields**:
- `id`: Generated tasker ID (`tsk-xxxxxxxx`)
- `parent_agent_id`: Spawning agent identifier
- `session_id`: Optional session association
- `chat_room_id`: Chat room for nag messages
- `task`: Task description
- `patterns`: JSON array of fabric patterns to apply
- `status`: Lifecycle state (idle/active/nagging/terminated)
- `timeout_minutes`: Auto-terminate timeout
- `nag_minutes`: Idle time before nag message
- `created_at`: Spawn timestamp
- `last_activity`: Last touch timestamp
- `terminated_at`: Termination timestamp
- `termination_reason`: Reason for termination

### Relationships

**Foreign Keys**:
- `chat_room_id` → `chat_rooms.id` (for nag messages)
- `session_id` → `sessions.id` (optional session grouping)

**Related Tables**:
- `chat_events` - Nag messages sent to parent agent
- `sessions` - Optional session grouping

## User Stories Mapping

This category addresses:
- **No explicit user stories mapped** (implementation exists without documented requirements)

Potential user stories:
- **US-XXX**: As an agent, I want to spawn ephemeral sub-agents for specific tasks
- **US-XXX**: As an agent, I want to analyze command output using fabric patterns
- **US-XXX**: As an agent, I want to receive notifications when taskers become idle
- **US-XXX**: As a user, I want taskers to auto-terminate after timeouts

## Suggested PRD Mapping

- **PRD-10**: External Executor Management
- **PRD-11**: Fabric CLI Integration for Output Analysis

## API Documentation

### MCP Tools

**⚠️ NOT EXPOSED**: Implementation exists but no MCP tools registered.

### Web Endpoints (if applicable)

**No web endpoints** currently exist for tasker management.

Potential endpoints:
- `GET /api/taskers` - List active taskers
- `GET /api/tasker/{id}` - Get tasker details
- `POST /api/tasker/{id}/dismiss` - Dismiss tasker
- `POST /api/tasker/{id}/keep-alive` - Respond to nag

## Dependencies

### Internal
- **Chat System** (C-05) - For nag message delivery
- **Session Management** (C-04) - Optional session grouping
- **Database Layer** (C-02) - Tasker persistence

### External
- **Fabric CLI** - Optional LLM analysis tool (https://github.com/danielmiessler/fabric)
- **asyncio** - Async lifecycle monitoring
- **subprocess** - Fabric CLI invocation

## Testing

- **Test Files**: Not documented in PROJECT_STATUS.md
- **Coverage**: Unknown
- **Key Test Cases**: None documented

**Testing gaps**:
- Tasker lifecycle state transitions
- Timeout and nag behavior
- Fabric pattern application
- Chat notification delivery
- Context buffering for follow-ups

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (no executor section)
- **USAGE**: No usage documentation for executors
- **PRD**: Not mentioned in existing PRDs
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (no executor coverage data)
- **ENHANCEMENTS**: worktrees/main/mcp-server/docs/ENHANCEMENTS.md (no executor plans)

## Implementation Notes

### Critical Observations

1. **Complete but Hidden**: Full implementation exists with lifecycle management, fabric integration, and DB schema, but **zero exposure via MCP tools**.

2. **No Integration Point**: The `TaskerManager` is instantiated in the codebase but never exposed through the MCP tool registry.

3. **Chat Integration Ready**: Built to send nag messages via `ChatManager` but no documented use cases.

4. **Context Buffering**: Supports follow-up queries by storing command history and last outputs, suggesting intended interactive use.

5. **Fabric Dependency**: Falls back gracefully if fabric not installed, but optimal use requires external tool.

### Design Patterns

**Lifecycle Monitor Pattern**: Background asyncio task checks all taskers every 30 seconds for timeout/nag conditions.

**Context Caching**: Dual-layer storage with in-memory `_contexts` dict for hot data and DB for persistence.

**Graceful Degradation**: Fabric integration returns truncated raw content if CLI unavailable.

### Limitations

- No MCP tools exposed despite complete implementation
- No web UI for tasker monitoring
- No real-time tasker status updates
- Fabric CLI must be installed separately
- Context buffer limited to last 10 commands
- No tasker metrics/analytics

### Integration Opportunities

**Potential Use Cases**:
1. **Sub-agent Spawning**: Primary agent spawns taskers for parallel work
2. **Test Analysis**: Spawn tasker to analyze test output with fabric patterns
3. **Log Investigation**: Ephemeral agents for log analysis with auto-cleanup
4. **Background Tasks**: Long-running operations with nag-based status updates

**MCP Tool Integration**:
```python
@mcp.tool()
async def spawn_tasker(
    task: str,
    chat_room_id: int,
    parent_agent_id: str = "primary",
    patterns: Optional[List[str]] = None,
    session_id: Optional[str] = None,
    timeout_minutes: int = 15
) -> dict:
    """Spawn ephemeral tasker agent for specific task."""
    return await _tasker_manager.spawn_tasker(...)

@mcp.tool()
async def analyze_with_fabric(
    content: str,
    patterns: List[str],
    combine_results: bool = True
) -> dict:
    """Analyze content using fabric patterns."""
    from .executors.fabric import analyze_with_patterns
    return await analyze_with_patterns(content, patterns, combine_results)
```

### Gotchas

- **Fabric Installation**: User must install fabric CLI separately from PyPI or GitHub
- **Pattern Names**: Fabric pattern names must match exactly (case-sensitive)
- **Timeout Defaults**: 15-minute default may be too short for complex analysis
- **Nag Frequency**: 5-minute idle + 2-minute nag window = aggressive lifecycle
- **Context Loss**: In-memory context lost on server restart (not DB-backed)

### Future Enhancements

From code comments and structure:
1. Expose MCP tools for tasker management
2. Add web UI for tasker monitoring dashboard
3. Persist context buffer to database
4. Add tasker analytics (avg lifetime, completion rate)
5. Support custom fabric pattern directories
6. Add tasker pooling/queueing for resource limits
7. Integrate with task queue system (C-09)
8. Add real-time WebSocket updates for tasker status
