# Task Queue Listener Command

This command instructs the agent to listen for changes on a task queue and process tasks.

## Arguments
- `$ARGUMENTS` - Queue ID or name to listen to

## Instructions

You are now entering **Task Queue Listener Mode** for queue: `$ARGUMENTS`

### Setup

1. First, use the `list_task_queues` MCP tool to find the queue ID if only a name was provided
2. Use `get_task_queue` to get the queue details and verify it exists
3. Store the queue_id for subsequent operations

### Polling Loop

You should poll for updates using the following workflow:

1. **Initial Fetch**: Call `get_task_queue_feed` with `queue_id` and no `since` parameter to get recent events
2. **Store Timestamp**: Save the `next_since` value from the response
3. **Process Events**: For each event in the feed:
   - `task_created`: Review the new task, assign complexity using `assign_task_complexity`
   - `status_changed`: Acknowledge status changes
   - `message`: Respond to questions by calling `add_task_message`
   - `artifact_added`: Acknowledge artifact uploads

4. **Check Pending Tasks**: Call `list_tasks` with `status=pending` to find tasks waiting for work
   - For each pending task assigned to you or unassigned:
     - Use `update_task_status` to mark as `in_progress`
     - Work on the task
     - Upload results using `add_task_artifact` (artifact or git_branch)
     - Update status to `review` when done (human will mark `done`)

5. **Poll Again**: After processing, call `get_task_queue_feed` with the stored `since` parameter
6. **Repeat**: Continue the loop, pausing briefly between polls

### API Endpoints for Reference

The MCP server exposes these polling endpoints:

```
GET /api/tasks/queues/{queue_id}/feed?since={timestamp}&limit=100
```

Returns:
```json
{
  "events": [...],
  "next_since": "2024-01-15T12:34:56.789",
  "queue_id": 1
}
```

### SSE Stream (Alternative)

For real-time updates, agents can connect to the SSE endpoint:

```
GET /api/tasks/queues/{queue_id}/stream
```

This streams events as they occur in Server-Sent Events format.

### Claude Code Hook Integration

For automatic context injection, configure Claude Code hooks to check for task queue updates.
This injects updates as context after MCP tool calls without requiring explicit polling.

**Setup:**

1. Copy `core/hooks/task-queue.example.json` to `.claude/task-queue.json`
2. Set your `queue_id` in the config
3. Add hook configuration from `core/hooks/task-queue-settings.example.json` to `.claude/settings.json`

**How it works:**
- `PostToolUse` hook fires after MCP tool calls
- `SessionStart` hook fires when session begins
- Hook checks `/api/tasks/queues/{queue_id}/feed` with cursor tracking
- New events are injected as `additionalContext`

This provides passive notifications without explicit polling calls.

### Status Flow

Tasks follow this status progression:
- `pending` - Task created, waiting to be picked up
- `in_progress` - Agent is actively working on it
- `blocked` - Agent encountered an issue, needs help
- `review` - Agent completed work, awaiting human review
- `done` - Human operator approved the work (only human can set this)

### Best Practices

1. **Assign Complexity First**: When you see a new task, review it and call `assign_task_complexity` with:
   - 1 = Trivial (minutes)
   - 2 = Simple (under an hour)
   - 3 = Moderate (few hours)
   - 4 = Complex (day or more)
   - 5 = Very Complex (multi-day effort)

2. **Ask Questions**: Use `add_task_message` to ask clarifying questions before starting work

3. **Upload Progress**: Use `add_task_artifact` to share:
   - `artifact_type="git_branch"` with `git_branch="feature/task-123"` for code
   - `artifact_type="artifact"` with `artifact_id` for uploaded files
   - `artifact_type="file"` with `description` for general files

4. **Update Status Appropriately**:
   - Mark `blocked` if you need human input to proceed
   - Mark `review` only when you've completed all acceptance criteria

### Example Session

```
# Get queue info
get_task_queue(queue_id=1)

# Get initial feed
feed = get_task_queue_feed(queue_id=1)
# -> next_since: "2024-01-15T12:00:00"

# Process any pending tasks
tasks = list_tasks(queue_id=1, status="pending")
for task in tasks:
    # Review and assign complexity
    assign_task_complexity(task_id=task.id, complexity=2, notes="Standard feature", persona="agent")

    # Start work
    update_task_status(task_id=task.id, status="in_progress", persona="agent")

    # ... do the work ...

    # Share results
    add_task_artifact(task_id=task.id, artifact_type="git_branch", git_branch="feature/task-123", created_by="agent")

    # Request review
    update_task_status(task_id=task.id, status="review", persona="agent", notes="Completed per acceptance criteria")

# Poll for updates
while True:
    feed = get_task_queue_feed(queue_id=1, since=feed.next_since)
    # Process new events...
    # Wait a bit before next poll
```

Now begin listening to the task queue. Start by fetching the queue details and initial feed.
