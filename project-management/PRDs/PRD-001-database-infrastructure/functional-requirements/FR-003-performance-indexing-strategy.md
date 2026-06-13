# FR-003: Performance Indexing Strategy

**Status**: Completed

## Description

Comprehensive indexing strategy for query optimization across all 15 tables. Indexes cover foreign key relationships, timestamp-based queries, and status filtering.

## Indexes Created

### Artifact & Review System
- `idx_revisions_artifact` - Revision history queries
- `idx_reviews_artifact`, `idx_reviews_revision` - Review lookups
- `idx_inline_comments_review` - Comment retrieval

### Chat System
- `idx_chat_events_room` - Event feed by room
- `idx_chat_events_timestamp` - Chronological ordering
- `idx_notifications_persona` - User notifications
- `idx_notifications_read` - Unread notification filtering

### Session Management
- `idx_sessions_updated` - Recent sessions ordering
- `idx_sessions_status` - Session status filtering
- `idx_artifacts_session` - Artifacts by session
- `idx_chat_rooms_session` - Rooms by session

### Task System
- `idx_taskers_status`, `idx_taskers_session`, `idx_taskers_parent` - Tasker lookups
- `idx_task_queues_status`, `idx_task_queues_session` - Queue filtering
- `idx_tasks_queue`, `idx_tasks_status`, `idx_tasks_priority` - Task queries
- `idx_tasks_deadline`, `idx_tasks_assigned` - Task filtering
- `idx_task_events_task`, `idx_task_events_queue`, `idx_task_events_created` - Event feeds
- `idx_task_artifacts_task`, `idx_task_artifacts_artifact` - Artifact links

## Interface

Indexes are created automatically as part of schema.sql:

```sql
CREATE INDEX idx_chat_events_room ON chat_events(room_id);
CREATE INDEX idx_chat_events_timestamp ON chat_events(timestamp);
```

## Behavior

- **Given** query filters by foreign key (e.g., room_id)
- **When** SELECT executes
- **Then** index scan used instead of full table scan

- **Given** query orders by timestamp
- **When** ORDER BY timestamp DESC executes
- **Then** index enables efficient chronological sorting

## Edge Cases

- **Composite queries**: Multiple indexes may be used (e.g., room_id + timestamp)
- **Full table scans**: Small tables may skip index if optimizer determines scan is faster
- **Index bloat**: Frequent updates may fragment indexes (REINDEX needed periodically)
- **Write overhead**: Indexes increase INSERT/UPDATE cost slightly

## Related User Stories

- US-040
- US-046

## Test Coverage

Expected test count: 0 (performance testing not in scope)
Target coverage: Implicit (indexes created as part of schema)
Actual coverage: N/A (no explicit index tests)
