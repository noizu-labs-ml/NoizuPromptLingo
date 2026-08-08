---
name: listen-task-queue
description: Enter Task Queue Listener Mode for a given queue ID or name. Runs a Monitor on Notifications.Poll to wake the instant queue activity arrives, assigns complexity, processes pending work, uploads artifacts, and manages status transitions through the pending → in_progress → review lifecycle.
---

# Task Queue Listener Command

Enter **Task Queue Listener Mode** for queue: `$ARGUMENTS`

## Arguments
- `$ARGUMENTS` — Queue ID or name to listen to

---

## Setup

1. Use the `list_task_queues` MCP tool to find the queue ID if only a name was provided
2. Use `get_task_queue` to get the queue details and verify it exists
3. Store the queue_id for subsequent operations

---

## Notification Loop (Monitor)

Do not poll on a timer. Instead, run a **Monitor** on `Notifications.Poll`. It holds open for a few minutes and returns the instant a notification arrives — a task assignment, a message on one of your tasks, a follow-up coming due, a mention, or a ping — so you react immediately rather than waking on a clock.

1. **Watch the queue**: Call `Notifications.Watch` on the task queue (and on each task you pick up) so queue activity is delivered to your inbox. Do an initial `get_task_queue_feed` once to catch up on anything that happened before you joined.
2. **Run the Monitor**: Start a Monitor on `Notifications.Poll`. It returns as soon as one or more notifications arrive.
3. **Process each notification**: For each returned notification:
   - task assignment / `task_created` → review the task, assign complexity using `assign_task_complexity`
   - `message` on a task → answer with `add_task_message` (replying marks the related notifications read)
   - `status_changed` / `artifact_added` → acknowledge
   - ping → reply with a short status digest via `Notify pong_to:<notification_id>`
   - PubSub channel availability → `Notifications.Ack` (or `PubSub.Ack`)

   Mark each handled item with `Notifications.MarkSeen` / `Notifications.MarkRead`.

4. **Pick up pending work**: Call `list_tasks` with `status=pending` to find tasks waiting for work
   - For each pending task assigned to you or unassigned:
     - Use `update_task_status` to mark as `in_progress`
     - Work on the task
     - Upload results using `add_task_artifact` (artifact or git_branch)
     - Update status to `review` when done (human will mark `done`)

5. **Resume the Monitor**: Return to step 2. There is no poll interval to tune — the Monitor wakes you the moment new work lands.

---

## New Coordination Capabilities

These inbox/notify tools back the loop above and are available at any time:

- **Notify** — send a short DM (≤128 chars) to a user, a list of users, a group, or a list of groups. This is how you reach out to teammates (it replaces the old outbound pipe).
- **Mentions vs digest cadence** — `@everyone` or `@your-handle` in chat notifies you immediately; ordinary channel chatter is folded into a 5-minute rolling digest so routine lines don't wake you one at a time.
- **Ping → Pong** — a `Notify` with `ping:true` (body optional) may be broadcast to a group; on receiving a ping, reply with a short status digest via `Notify pong_to:<notification_id>`.
- **Notifications.FollowUp** — remind yourself about an item in N minutes/hours.
- **Notifications.Watch (with filters)** — watch a ticket, chat room, thread, wiki page, artifact, or an agent's online/offline state, with an optional substring/regex filter (e.g. only notify on messages starting with `!!!`).
- **Notifications.Share** — share an artifact, chat message, wiki page, or asset into a room, thread, or DM.
- **Convert to ticket** — `Ticket.FromEntity` turns a chat message, artifact, or asset into a tracked ticket.
- **PubSub follow / ack** — `PubSub.Follow` and `PubSub.Ack` for channel availability.
- **Chat hygiene** — `mute`, `mute_unless_mentioned`, or `leave` a room. After reading a room's messages and acting, mark them seen; replying to a chat message marks the related notifications read.

Inbox tools: `Notifications.Get`, `Notifications.Poll`, `Notifications.MarkRead`, `Notifications.MarkSeen`, `Notifications.Ack`, `Notifications.Clear`, `Notifications.Watch`, `Notifications.FollowUp`, `Notifications.Share`.

---

## API Endpoints for Reference

The Monitor on `Notifications.Poll` is the preferred mechanism. For lower-level catch-up or debugging, the MCP server still exposes these feed endpoints:

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

---

## SSE Stream (Lower-Level)

The Monitor on `Notifications.Poll` is built on the same real-time delivery. If you need the raw stream directly, agents can connect to the SSE endpoint:

```
GET /api/tasks/queues/{queue_id}/stream
```

This streams events as they occur in Server-Sent Events format.

---

## Claude Code Hook Integration

For automatic context injection, configure Claude Code hooks to check for task queue updates. This injects updates as context after MCP tool calls without requiring explicit polling.

**Setup:**

1. Copy `core/hooks/task-queue.example.json` to `.claude/task-queue.json`
2. Set your `queue_id` in the config
3. Add hook configuration from `core/hooks/task-queue-settings.example.json` to `.claude/settings.json`

**How it works:**
- `PostToolUse` hook fires after MCP tool calls
- `SessionStart` hook fires when session begins
- Hook checks `/api/tasks/queues/{queue_id}/feed` with cursor tracking
- New events are injected as `additionalContext`

This provides passive notifications without holding a Monitor open.

---

## Status Flow

Tasks follow this status progression:
- `pending` — Task created, waiting to be picked up
- `in_progress` — Agent is actively working on it
- `blocked` — Agent encountered an issue, needs help
- `review` — Agent completed work, awaiting human review
- `done` — Human operator approved the work (only human can set this)

---

## Best Practices

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

---

## Example Session

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

# React to new work via a Monitor (no timer)
Notifications.Watch(target="task_queue:1")
while True:
    notes = Monitor(Notifications.Poll)   # returns the instant something arrives
    for n in notes:
        # handle task_created / message / status_changed / ping ...
        Notifications.MarkSeen(notification_id=n.id)
    # then resume the Monitor
```

Now begin listening to the task queue. Start by fetching the queue details, watching the queue, and running a Monitor on `Notifications.Poll`.
