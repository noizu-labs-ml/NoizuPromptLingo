# User Story: Spawn Ephemeral Tasker Agents

**ID**: US-094
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Documented
**Created**: 2026-02-02

## Story

As an **AI agent**,
I want to **spawn ephemeral sub-agents (taskers) for specific tasks with automatic lifecycle management**,
So that **I can delegate work and receive notifications when taskers become idle or complete**.

## Acceptance Criteria

- [ ] Can spawn tasker with task description and fabric patterns
- [ ] Tasker automatically generates unique ID (`tsk-xxxxxxxx`)
- [ ] Tasker tracks lifecycle states: IDLE, ACTIVE, NAGGING, TERMINATED
- [ ] Tasker sends "nag" message to parent after idle period (default: 5 minutes)
- [ ] Parent can respond with `keep_alive` to extend timeout
- [ ] Tasker auto-terminates after timeout (default: 15 minutes)
- [ ] Can manually dismiss tasker with reason
- [ ] Tasker context buffered for follow-up queries

## Implementation Status

✅ **Implemented in mcp-server worktree but NOT exposed as MCP tools**

### Potential MCP Tools (Not Exposed)

- `spawn_tasker(task, chat_room_id, parent_agent_id, patterns, session_id, timeout_minutes, nag_minutes)` - Spawn ephemeral agent
- `get_tasker(tasker_id)` - Get tasker status and metadata
- `list_taskers(status, session_id)` - List active taskers
- `dismiss_tasker(tasker_id, reason)` - Manually terminate tasker
- `keep_alive_tasker(tasker_id)` - Respond to nag and extend timeout

### Source Files

- Implementation: `worktrees/main/mcp-server/src/npl_mcp/executors/manager.py`
- Database Schema: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql` (taskers table)
- **NOTE**: Tools NOT registered in `worktrees/main/mcp-server/src/npl_mcp/unified.py`

### Database Tables

- `taskers` - Tasker registry with state, timeouts, patterns, lifecycle tracking

### Documentation Briefs

- **Category Brief**: `.tmp/mcp-server/categories/10-external-executors.md`
- **Tool List**: `.tmp/mcp-server/tools/by-category/executor-tools.yaml`

## Example Usage

```python
# Spawn tasker for test analysis
tasker = await spawn_tasker(
    task="Analyze test failures in auth module",
    chat_room_id=42,
    parent_agent_id="primary",
    patterns=["analyze_logs", "extract_wisdom"],
    timeout_minutes=15,
    nag_minutes=5
)
# Returns: {"tasker_id": "tsk-a3f7k2m9", "status": "idle", ...}

# Keep alive after nag notification
await keep_alive_tasker("tsk-a3f7k2m9")

# Dismiss when done
await dismiss_tasker("tsk-a3f7k2m9", reason="task_complete")
```

## Lifecycle Flow

1. **Spawn**: Create tasker with task description, patterns, chat room
2. **Active**: Tasker executes commands, updates last_activity timestamp
3. **Idle**: No activity for `nag_minutes` → send nag message to chat room
4. **Nagging**: Parent has 2 minutes to respond with `keep_alive`
5. **Terminated**: Auto-dismiss after timeout or explicit dismissal

## Notes

- **CRITICAL**: Full implementation exists but MCP tools NOT exposed in `unified.py`
- Background lifecycle monitor checks taskers every 30 seconds
- Context buffer stores last 10 commands for follow-up queries
- Nag messages sent via chat system to designated room

## Related Stories

- US-014: Pick Up Task from Queue
- US-032: Assign Tasks to Specific Agents
- US-058: Facilitate Multi-Persona Consensus
- US-064: Agent Handoff Protocol
