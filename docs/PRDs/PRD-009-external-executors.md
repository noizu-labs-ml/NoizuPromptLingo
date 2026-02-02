# PRD: External Executors

**PRD ID**: PRD-009
**Version**: 1.0
**Status**: Implemented (Not Exposed)
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

Infrastructure for ephemeral tasker agents with automatic lifecycle management and Fabric CLI integration for LLM-based output analysis. **Complete implementation exists but NO MCP tools are currently exposed.**

**Implementation Status**: ⚠️ Implemented but not exposed via MCP tools

## Features Documented

### User Stories Addressed
None explicitly mapped (implementation exists without documented requirements)

## Functional Requirements

### FR-001: Ephemeral Tasker Lifecycle Management
**Implementation**: TaskerManager class (src/npl_mcp/executors/manager.py)
**Lifecycle States**: IDLE, ACTIVE, NAGGING, TERMINATED
**Database**: taskers table
**Features**:
- Auto-terminate after timeout (default: 15 minutes)
- Send nag messages after idle period (default: 5 minutes)
- Context buffering for follow-up queries
- In-memory state cache with persistent DB storage

**Key Methods** (not exposed as MCP tools):
- `spawn_tasker(task, chat_room_id, patterns, session_id, timeout, nag_minutes)`
- `get_tasker(tasker_id)`, `list_taskers(status, session_id)`
- `touch_tasker(tasker_id)`, `keep_alive(tasker_id)`
- `store_context(tasker_id, command, raw_output, analysis, result)`
- `get_context(tasker_id)`, `dismiss_tasker(tasker_id, reason)`
- `start_lifecycle_monitor()`, `stop_lifecycle_monitor()`

### FR-002: Fabric CLI Integration
**Implementation**: fabric module (src/npl_mcp/executors/fabric.py)
**External Dependency**: danielmiessler/fabric CLI
**Features**:
- Auto-detect fabric installation
- Apply single or multiple patterns
- Pattern selection heuristics
- Graceful fallback when fabric unavailable

**Common Patterns**: summarize, extract_wisdom, analyze_logs, explain_code, extract_main_idea, analyze_claims, create_summary

**Key Functions** (not exposed as MCP tools):
- `find_fabric() -> Optional[Path]`
- `apply_fabric_pattern(content, pattern, model, timeout) -> Dict`
- `analyze_with_patterns(content, patterns, combine_results) -> Dict`
- `list_patterns() -> Dict`
- `select_pattern_for_task(task_type) -> str`

## Data Model

**taskers**: id (TEXT PRIMARY KEY), parent_agent_id, session_id, chat_room_id, task, patterns (JSON), status, timeout_minutes, nag_minutes, created_at, last_activity, terminated_at, termination_reason

**Indexes**: status, session_id, parent_agent_id

## Lifecycle Flow

1. **Spawn**: Create tasker with task, patterns, chat room
2. **Idle**: Awaiting first command
3. **Active**: Executing commands, updating last_activity
4. **Nagging**: No activity for nag_minutes → send nag message (2-minute response window)
5. **Terminated**: Auto-dismiss after timeout or explicit dismissal

## Potential MCP Tools (Not Yet Implemented)

### Tasker Management
- `spawn_tasker(...)` - Create ephemeral tasker
- `get_tasker(tasker_id)` - Get tasker details
- `list_taskers(status, session_id)` - List taskers
- `dismiss_tasker(tasker_id, reason)` - Terminate tasker
- `keep_alive_tasker(tasker_id)` - Respond to nag

### Fabric Integration
- `apply_fabric_pattern(content, pattern, ...)` - Apply single pattern
- `analyze_with_fabric(content, patterns, ...)` - Apply multiple patterns
- `list_fabric_patterns()` - List available patterns

## Dependencies
- **Internal**: Chat Manager (nag messages), Session Manager, Database
- **External**: Fabric CLI (optional), asyncio

## Testing
- **Coverage**: Unknown (not documented)
- **Test Files**: None found

## Critical Gap

**⚠️ IMPORTANT**: This category has complete implementation with lifecycle management, fabric integration, and DB schema, but **zero exposure via MCP tools**. The `TaskerManager` is instantiated in the codebase but never exposed through the MCP tool registry in `unified.py`.

## Recommended Next Steps

1. Expose MCP tools in unified.py
2. Add test coverage for lifecycle management
3. Document usage patterns in USAGE.md
4. Add web UI for tasker dashboard
5. Create PRD for executor features
6. Integrate with task queue system
7. Add real-time WebSocket updates

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/10-external-executors.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/executor-tools.yaml`
