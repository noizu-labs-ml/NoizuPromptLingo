# User Story: Expose Executor Lifecycle Tools

**ID**: US-0102
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: High
**Status**: Draft
**PRD Group**: executor_exposure
**Created**: 2026-02-02

## As a...
DevOps engineer managing distributed agents

## I want to...
Expose executor lifecycle management as MCP tools for monitoring and control

## So that...
Agents can query status, keep executors alive, and gracefully terminate worker agents

## Acceptance Criteria
- [ ] `get_tasker` MCP tool registered (retrieve executor details)
- [ ] `list_taskers` MCP tool registered (query active executors)
- [ ] `touch_tasker` MCP tool registered (keep-alive heartbeat)
- [ ] `dismiss_tasker` MCP tool registered (graceful termination)
- [ ] `keep_alive_tasker` MCP tool registered (prevent idle timeout)
- [ ] Status commands working (active, idle, terminated, failed states)
- [ ] Test coverage 80%+ for all lifecycle operations
- [ ] Tool integration with executor manager.py verified

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/10-external-executors.md`

**Tools to Expose**:

**1. get_tasker**
```
get_tasker(executor_id: str) -> dict
Returns: {executor_id, type, status, created_at, last_heartbeat, expires_at, context}
```

**2. list_taskers**
```
list_taskers(
  status: str = None,    # Filter by: spawned, running, idle, terminated, failed
  owner_id: str = None   # Filter by owner/creator
) -> list[dict]
```

**3. touch_tasker**
```
touch_tasker(executor_id: str) -> dict
Returns: {executor_id, status, heartbeat_at, expires_at}
Note: Updates last_heartbeat timestamp, resets idle timeout
```

**4. dismiss_tasker**
```
dismiss_tasker(executor_id: str, reason: str = "user_request") -> dict
Returns: {executor_id, status: "terminated", reason, terminated_at}
Note: Graceful shutdown with context cleanup
```

**5. keep_alive_tasker**
```
keep_alive_tasker(executor_id: str, extend_by: int = 300) -> dict
Returns: {executor_id, status, old_expires_at, new_expires_at}
Note: Extend expiration by X seconds (default 300s)
```

**Executor Status States**:
- `spawned`: Initial state after spawn_tasker
- `running`: Executor responsive to heartbeat
- `idle`: No activity for idle_timeout threshold
- `terminated`: Gracefully shut down (via dismiss_tasker)
- `failed`: Process exited unexpectedly

**Implementation Location**:
- Core: `src/npl_mcp/executor/manager.py` (already exists)
- Registration: `src/npl_mcp/unified.py` (needs MCP tool decorators)

**Database Table**: taskers
- id (executor_id)
- type (agent type)
- status (state enum)
- owner (creator/owner)
- context (BLOB with executor context)
- created_at
- last_heartbeat (updated by touch)
- expires_at (updated by keep_alive)

**Operations**:

**get_tasker**:
- Query taskers table by id
- Return full metadata
- Handle non-existent executor (404 or None)

**list_taskers**:
- Query with optional status and owner filters
- Return list of executor metadata dicts
- Order by creation or last_heartbeat

**touch_tasker**:
- Update last_heartbeat to now
- Reset expires_at = now + idle_timeout
- Return updated metadata

**keep_alive_tasker**:
- Extend expires_at by specified seconds
- Update last_heartbeat to now
- Return old and new expiration times

**dismiss_tasker**:
- Update status to "terminated"
- Trigger graceful shutdown (process signal)
- Cleanup context/resources
- Record termination reason
- Return final metadata

**Test Scenarios**:
- Get existing executor (success)
- Get non-existent executor (error)
- List all executors
- List by status filter
- List by owner filter
- Touch executor (heartbeat update)
- Touch non-existent executor (error)
- Keep alive extends expiration
- Keep alive on terminated executor (error)
- Dismiss gracefully terminates
- Dismiss non-existent executor (error)
- Status transitions (spawn → running → idle)
- Concurrent lifecycle operations

## Related Stories
- US-101 (Expose Executor Spawn Tool)
- US-100 (Add Executor System Test Suite)
- US-103 (Expose Fabric Pattern Tools)
- US-050 (Agent Performance Metrics Dashboard)
- US-059 (Chain Multi-Agent Workflows with Dependencies)

## Notes
Lifecycle tools provide monitoring and control for spawned executors. Implementation exists in manager.py but not exposed. Touch/keep-alive operations critical for preventing unwanted timeouts. Dismiss provides graceful shutdown path. Status queries essential for orchestration logic (conditional branching based on executor state). These tools complete the executor control plane.
