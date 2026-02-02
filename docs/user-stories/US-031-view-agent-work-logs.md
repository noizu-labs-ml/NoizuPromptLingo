# User Story: View Agent Work Logs

**ID**: US-031
**Persona**: P-004 (Project Manager)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z

## Story

As a **project manager**,
I want to **view detailed work logs of what agents have accomplished**,
So that **I can track progress, identify patterns, and report to stakeholders**.

## Context

This user story addresses the **NPL MCP work log tracking system**, which provides visibility into agent activity across tasks, artifacts, and sessions. Work logs capture timestamped entries for agent actions including task status changes, artifact creation/updates, chat messages, and other system interactions. This is distinct from task queue progress (US-015), which focuses on high-level task status - work logs provide granular action-level tracing for debugging, auditing, and pattern analysis.

## Acceptance Criteria

### MCP Tool Requirements
- [ ] `get_agent_work_log` tool retrieves agent activity entries with filtering by:
  - Agent/persona ID
  - Task ID or task queue ID
  - Session ID
  - Time range (start_time, end_time)
  - Action type (task_update, artifact_create, message_sent, etc.)
- [ ] Each log entry includes:
  - Timestamp (ISO 8601 format)
  - Agent/persona ID
  - Action type (task_update, artifact_create, artifact_revision, message_sent, status_change, etc.)
  - Target resource (task_id, artifact_id, room_id, etc.)
  - Action outcome (success, failure, partial)
  - Duration (milliseconds) for completed actions
  - Error details (for failed actions with retry count)
  - Context metadata (related resources, parent task, session)
- [ ] Failed actions include error message, stack trace (if available), and retry attempt count
- [ ] `export_work_log` tool generates CSV/JSON export for reporting
- [ ] `get_agent_metrics` tool provides summary statistics:
  - Total actions (by type)
  - Success/failure rate
  - Average action duration
  - Time spent on tasks
  - Tasks completed count

### Web UI Requirements
- [ ] Work log dashboard accessible via FastAPI route (e.g., `/logs` or `/agents/logs`)
- [ ] Filterable table view with search by agent, task, session, date range
- [ ] Summary cards showing key metrics (actions today, success rate, top agents)
- [ ] Timeline view showing chronological agent activity
- [ ] Action detail view on click (full context, error details, related resources)
- [ ] Export button for filtered log data (CSV or JSON download)
- [ ] Real-time updates via SSE when new agent actions occur
- [ ] Dashboard performs efficiently with 1000+ log entries (pagination required)

## Technical Notes

- **Immutability**: Work log entries are append-only; once written they cannot be modified (only soft-deleted if needed)
- **Privacy considerations**: Agent internal reasoning (LLM prompts/completions) should not be logged; only high-level actions and outcomes
- **Log rotation**: Consider automatic archival of logs older than 90 days to maintain database performance
- **Performance**: Index on timestamp, agent_id, task_id, session_id for efficient filtering
- **Architecture**: Work logging requires:
  - SQLite table `agent_work_log` with fields: log_id, timestamp, agent_id, action_type, target_type, target_id, outcome, duration_ms, error_message, retry_count, metadata (JSON)
  - Integration points: Task status changes (`update_task_status`), artifact operations (`create_artifact`, `add_revision`), chat messages (`send_message`)
  - Automatic logging wrapper for MCP tool calls to capture agent activity
- **Related to task feeds**: `get_task_feed` and `get_task_queue_feed` provide task-specific activity; work logs provide cross-cutting agent-centric view

## Testable Behavior

**Scenario 1: Project manager views today's agent activity**
```
Given: Agent "agent-01" completed 3 tasks, created 2 artifacts, sent 5 messages today
When: PM calls get_agent_work_log(agent_id="agent-01", start_time="2026-02-02T00:00:00Z")
Then: Returns 10 log entries (3 task_update + 2 artifact_create + 5 message_sent)
And: Each entry includes timestamp, action_type, target_id, outcome
And: Entries are sorted chronologically (newest first)
```

**Scenario 2: Filter logs by failed actions**
```
Given: Agent "agent-02" had 2 failed artifact_create attempts and 1 failed task_update
When: PM calls get_agent_work_log(agent_id="agent-02", outcome="failure", start_time="2026-02-01T00:00:00Z")
Then: Returns 3 failed action entries
And: Each entry includes error_message, retry_count, and failure timestamp
```

**Scenario 3: View agent metrics summary**
```
Given: Agent "agent-03" completed 15 actions (12 success, 3 failures) with avg duration 2500ms
When: PM calls get_agent_metrics(agent_id="agent-03", time_range="today")
Then: Returns summary:
  - total_actions: 15
  - success_rate: 80.0
  - avg_duration_ms: 2500
  - actions_by_type: {task_update: 8, artifact_create: 4, message_sent: 3}
```

**Scenario 4: Export work logs for reporting**
```
Given: Project has 200 agent work log entries in the last 7 days
When: PM calls export_work_log(start_time="2026-01-26T00:00:00Z", format="csv")
Then: Returns CSV file with columns: timestamp, agent_id, action_type, target_id, outcome, duration_ms, error_message
And: File includes all 200 entries
And: File is ready for import into spreadsheet or BI tool
```

**Scenario 5: Real-time work log updates in web UI**
```
Given: PM viewing work log dashboard at /logs
When: Agent "agent-04" updates task status to "completed"
Then: SSE event pushes new log entry to browser
And: Dashboard updates without page refresh
And: New entry appears at top of activity timeline
```

## Dependencies

- Task Queue system (US-014, US-015) - logs capture task status changes
- Session management (US-005) - logs are filterable by session
- Artifact system (US-008) - logs capture artifact creation and revision
- Chat system (US-006) - logs capture agent messages

## Open Questions

- [ ] **Granularity of logging**: Should individual MCP tool calls be logged, or only higher-level operations (e.g., task completion)? (Recommend: Log all MCP tool calls with filtering option to show only "significant" actions)
- [ ] **Token usage tracking**: Should logs include LLM token counts and estimated costs per action? (Recommend: Yes, add optional `token_count` and `estimated_cost` fields for auditing and budget tracking)
- [ ] **Agent reasoning visibility**: How much internal agent "thinking" (prompt engineering, retries, decision rationale) should be exposed vs. just final actions? (Recommend: Keep internal reasoning separate; work logs show actions only, but link to detailed execution traces if needed for debugging)
- [ ] **Retention policy**: How long should detailed work logs be retained before archiving? (Recommend: 90 days online, then archive to cold storage with option to restore)
- [ ] **Privacy and security**: Should work logs be persona-scoped (agents can only see their own logs) or globally visible to all project managers? (Recommend: Global visibility for PMs, restricted for other personas)
- [ ] **Integration with external tools**: Should work logs support webhook integrations for alerting (e.g., Slack notification when agent fails 3+ times)? (Consider for future enhancement)

## Related Commands

**Primary Commands** (to be implemented):
- `get_agent_work_log` (Agent Work Log Tools) - Retrieve filtered agent activity log
- `get_agent_metrics` (Agent Work Log Tools) - Get summary metrics for agent performance
- `export_work_log` (Agent Work Log Tools) - Export logs in CSV or JSON format

**Supporting Commands** (existing):
- `get_task_feed` (Task Queue Tools) - View task-specific activity (complementary to agent-centric view)
- `get_task_queue_feed` (Task Queue Tools) - View queue-level activity feed
- `get_chat_feed` (Chat Tools) - View agent messages in chat rooms
- `list_tasks` (Task Queue Tools) - List tasks to correlate with work log entries

## Implementation Notes

This feature requires:
1. **Database Schema**: `agent_work_log` table with fields: log_id, timestamp, agent_id, action_type, target_type, target_id, outcome, duration_ms, error_message, retry_count, metadata (JSON), token_count, estimated_cost
2. **Automatic Logging**: Middleware/decorator on MCP tools to auto-capture agent activity
3. **MCP Tool Registration**: Add Agent Work Log Tools to `src/npl_mcp/unified.py`
4. **FastAPI Routes**: Add work log dashboard routes to `src/npl_mcp/web/app.py`
5. **UI Components**: Dashboard templates or Next.js pages for log viewing and metrics
6. **Indexing**: Create indexes on (timestamp DESC, agent_id, task_id, session_id, outcome) for performant queries
