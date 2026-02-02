# User Story: Expose Executor Spawn Tool

**ID**: US-0101
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: High
**Status**: Draft
**PRD Group**: executor_exposure
**Created**: 2026-02-02

## As a...
DevOps engineer enabling distributed task execution

## I want to...
Make executor spawning available as an MCP tool for agents

## So that...
AI agents can dynamically spawn specialized worker agents for parallel tasks

## Acceptance Criteria
- [ ] `spawn_tasker` MCP tool registered in unified.py
- [ ] Tool accepts lifecycle parameters (agent_type, context, auto_spawn, idle_timeout)
- [ ] Tool returns executor ID, status, and chat_room_id for coordination
- [ ] Integrated with chat system for nag messages (keep-alive pings)
- [ ] Tool validation: Rejects invalid agent types, validates timeout values
- [ ] Test coverage 80%+ (includes spawn success, configuration validation)
- [ ] Documentation updated with tool signature and usage examples

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/10-external-executors.md`

**Tool Signature**:
```
spawn_tasker(
  agent_type: str,                # Type of agent to spawn (e.g., "coder", "debugger")
  context: dict,                   # Initial context/instructions for executor
  auto_spawn: bool = True,         # Auto-respawn on timeout (default: true)
  idle_timeout: int = 300,         # Seconds before idle termination (default: 300s)
  max_lifetime: int = 3600,        # Max lifetime before forced termination (default: 3600s)
) -> dict                          # Returns: {executor_id, status, chat_room_id}
```

**Returns**:
```json
{
  "executor_id": "exec-xyz789",
  "status": "spawned",
  "chat_room_id": "room-abc123",
  "expires_at": "2026-02-02T14:05:00Z"
}
```

**Implementation Location**:
- Core: `src/npl_mcp/executor/manager.py` (already exists)
- Registration: `src/npl_mcp/unified.py` (needs MCP tool decorator)

**Lifecycle Parameters**:
- `agent_type`: Validated against known agent types
- `context`: Dict with instructions, environment, constraints
- `auto_spawn`: If true, respawn on timeout; if false, terminate after timeout
- `idle_timeout`: Seconds of inactivity before idle state detection
- `max_lifetime`: Hard limit on executor lifetime (prevents runaway processes)

**Chat Room Integration**:
- Spawned executor linked to chat room for monitoring
- "Nag messages" send keep-alive pings if executor idle
- Chat room provides communication channel for executor status updates
- Original agent can send instructions via room messages

**Database**:
- taskers table: Stores executor metadata (id, type, status, created_at, expires_at)
- Linked to sessions via owner field
- Expiration tracking for cleanup

**Test Scenarios**:
- Spawn with minimal context
- Spawn with full configuration
- Invalid agent type rejected
- Invalid timeout values rejected
- Verify executor ID format and uniqueness
- Verify chat_room_id assigned and accessible
- Auto-spawn vs manual lifecycle
- Timeout and expiration handling

## Related Stories
- US-100 (Add Executor System Test Suite)
- US-102 (Expose Executor Lifecycle Tools)
- US-103 (Expose Fabric Pattern Tools)
- US-050 (Agent Performance Metrics Dashboard)

## Notes
Spawning is entry point to executor system. Implementation already exists in manager.py but not exposed as MCP tool. Chat room integration critical for monitoring and communication. Auto-spawn behavior important for reliability. Timeout parameters must be validated to prevent resource exhaustion.
