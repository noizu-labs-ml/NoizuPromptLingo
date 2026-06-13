# US-225: Cross-Agent Communication Through Shared Worklogs

## Story Information

| Field | Value |
|-------|-------|
| **Story ID** | US-225 |
| **Title** | Cross-Agent Communication Through Shared Worklogs |
| **Priority** | High |
| **Status** | Draft |
| **Related Personas** | P-005 (Dave) |
| **Related PRD** | PRD-014-cli-utilities.md |

---

## Description

As a developer, I want cross-agent communication through shared worklogs.

This enables multi-agent orchestration where agents communicate via shared worklog sessions: parent agents spawn child agents in session context, child agents write results to worklog, parent agents retrieve and process results asynchronously.

---

## Acceptance Criteria

- [ ] **AC-1**: `npl-session` CLI creates/manages worklog-based sessions
- [ ] **AC-2**: Sessions are identified by unique ID for reference
- [ ] **AC-3**: Child agents inherit session context and write to shared worklog
- [ ] **AC-4**: Parent agents can retrieve child worklog entries
- [ ] **AC-5**: Worklogs persist across agent spawning and execution
- [ ] **AC-6**: Session state includes: tasks, results, errors, metadata
- [ ] **AC-7**: Supports querying session state: tasks, progress, results

---

## Technical Notes

- Session storage: Database-backed (SQLite) with file-based backup option
- Worklog format: Structured log entries with timestamp, agent_id, entry_type, data
- Retrieval API: Query by session_id, agent_id, entry_type, timestamp range
- Parent-child binding: Environment variables pass session_id to child agents
- Async retrieval: Parent can poll or listen for worklog updates

---

## Dependencies

- Session management database
- Worklog schema and storage
- Session creation/query CLI
- Environment variable passing for child agents

---

## Test Coverage Requirements

- Unit tests for session creation and retrieval
- Tests for worklog entry persistence
- Tests for parent-child communication
- Tests for concurrent access (multiple agents)
- Tests for session cleanup
- Edge cases: session loss, stale entries, concurrent writes
- Target coverage: 80%+ for new code paths
