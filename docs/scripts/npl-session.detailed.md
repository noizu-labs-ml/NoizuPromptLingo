# npl-session (Detailed Reference)

Complete reference for session and worklog management in cross-agent communication.

## Overview

`npl-session` enables multiple agents to share a common worklog within a session. Each agent maintains its own read cursor, allowing incremental reads of entries added by other agents.

**Key concepts:**
- **Session**: A directory containing metadata, worklog, and cursors
- **Worklog**: Append-only JSONL file of entries from all agents
- **Cursor**: Per-agent pointer tracking last-read sequence number
- **Agent ID**: Unique identifier for each agent instance

## Session Structure

```
.npl/sessions/<session-id>/
├── meta.json           # Session metadata (status, task, created)
├── worklog.jsonl       # Shared entry log (append-only)
├── .cursors/           # Per-agent read cursors
│   └── <agent-id>.cursor
└── tmp/                # Temporary files (available for agent use)
```

Global state file:
```
.npl/current-session    # Contains active session ID
```

## Worklog Entry Schema

Each line in `worklog.jsonl` is a JSON object:

```json
{"seq":1,"ts":"2025-12-10T08:01:30Z","agent_id":"explore-auth-001","agent_type":"Explore","action":"file_found","summary":"Found 3 auth files","data":{"files":["auth.ts"]},"tags":["discovery"]}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `seq` | int | auto | Auto-incremented sequence number (1-based) |
| `ts` | string | auto | ISO 8601 UTC timestamp |
| `agent_id` | string | yes | Unique agent instance identifier |
| `agent_type` | string | yes | Agent template type (Explore, Plan, Code, etc.) |
| `action` | string | yes | Action type (file_found, task_complete, error, etc.) |
| `summary` | string | yes | Human-readable summary |
| `data` | object | no | Structured payload for machine consumption |
| `tags` | array | no | Categorization tags for filtering |
| `refs` | object | no | References to other entries, files, or resources |

### Auto-Generated Fields

- `seq`: Assigned atomically during write using file locking
- `ts`: UTC timestamp at write time

## Command Reference

### init

Create a new session.

```bash
npl-session init [--id <id>] [--task <desc>]
```

| Option | Description |
|--------|-------------|
| `--id` | Custom session ID. Default: `YYYY-MM-DD` (date-based) |
| `--task` | Task description stored in `meta.json` |

**Behavior:**
- Creates session directory with `meta.json`, `worklog.jsonl`, `.cursors/`, `tmp/`
- Sets as current session (writes to `.npl/current-session`)
- If session already exists, prints warning and returns existing ID

**Output:** Session ID (stdout)

```bash
$ npl-session init --task="Implement user authentication"
2025-12-10

$ npl-session init --id=auth-feature --task="Auth feature work"
auth-feature
```

### current

Get the current active session ID.

```bash
npl-session current
```

**Output:** Session ID (stdout), or error message (stderr) with exit code 1 if no active session.

```bash
$ npl-session current
2025-12-10
```

### log

Append an entry to the session worklog.

```bash
npl-session log --agent=<id> --action=<type> --summary="<text>" [options]
```

| Option | Description |
|--------|-------------|
| `--agent` | Agent ID (required) |
| `--type` | Agent type (default: `unknown`) |
| `--action` | Action type (required) |
| `--summary` | Summary text (required) |
| `--data` | JSON payload string |
| `--tags` | Comma-separated tags |
| `--session` | Target session (default: current or auto-create) |

**Behavior:**
- Uses file locking (`fcntl.LOCK_EX`) for atomic writes
- Automatically assigns next sequence number
- Creates session if none exists (when `--session` not specified)

**Output:** Confirmation message with sequence number

```bash
$ npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found auth.ts in src/lib" \
    --data='{"file":"src/lib/auth.ts","lines":245}' \
    --tags="discovery,auth"
Logged entry #1 to session 2025-12-10
```

### read

Read new entries since the agent's cursor.

```bash
npl-session read --agent=<id> [options]
```

| Option | Description |
|--------|-------------|
| `--agent` | Agent ID for cursor tracking (required) |
| `--peek` | Read without updating cursor |
| `--since <N>` | Read entries after sequence N (overrides cursor) |
| `--session` | Target session (default: current) |
| `--json` | Output as JSON array |

**Behavior:**
- Returns entries where `seq > cursor`
- Updates cursor to highest seq read (unless `--peek`)
- `--since` overrides cursor but still updates it after read

**Default output format:**
```
[<seq>] <timestamp> <agent_id>: <action> - <summary>
```

**Examples:**

```bash
# Read new entries as primary agent
$ npl-session read --agent=primary
[1] 2025-12-10T08:01:30+00:00 explore-auth-001: file_found - Found auth.ts in src/lib
[2] 2025-12-10T08:02:15+00:00 explore-auth-001: analysis - Auth uses JWT tokens

# Peek without advancing cursor
$ npl-session read --agent=primary --peek

# Read entries after specific sequence
$ npl-session read --agent=monitor --since=5

# JSON output for programmatic use
$ npl-session read --agent=primary --json
[
  {
    "seq": 1,
    "ts": "2025-12-10T08:01:30+00:00",
    "agent_id": "explore-auth-001",
    "agent_type": "Explore",
    "action": "file_found",
    "summary": "Found auth.ts in src/lib",
    "data": {"file": "src/lib/auth.ts", "lines": 245},
    "tags": ["discovery", "auth"]
  }
]
```

### status

Show session status and statistics.

```bash
npl-session status [--session <id>] [--json]
```

| Option | Description |
|--------|-------------|
| `--session` | Target session (default: current) |
| `--json` | Output as JSON |

**Output fields:**
- `session_id`: Session identifier
- `status`: `active` or `closed`
- `created`: Creation timestamp
- `task`: Task description (if set)
- `entry_count`: Total worklog entries
- `agents`: List of agent IDs that have logged entries
- `last_entry`: Timestamp of most recent entry

```bash
$ npl-session status
Session: 2025-12-10
Status: active
Created: 2025-12-10T08:00:00+00:00
Task: Implement user authentication
Entries: 15
Agents: explore-auth-001, plan-auth-001, code-auth-001
Last activity: 2025-12-10T08:45:30+00:00

$ npl-session status --json
{
  "session_id": "2025-12-10",
  "status": "active",
  "created": "2025-12-10T08:00:00+00:00",
  "task": "Implement user authentication",
  "entry_count": 15,
  "agents": ["code-auth-001", "explore-auth-001", "plan-auth-001"],
  "last_entry": "2025-12-10T08:45:30+00:00"
}
```

### list

List all sessions.

```bash
npl-session list [--all] [--json]
```

| Option | Description |
|--------|-------------|
| `--all` | Include archived sessions |
| `--json` | Output as JSON array |

**Default output format:**
```
<marker> <session_id> [<status>] entries=<N> agents=<N>
```
- Marker: `*` for current session, space otherwise

```bash
$ npl-session list
* 2025-12-10 [active] entries=15 agents=3
  2025-12-09 [closed] entries=42 agents=5
  2025-12-08 [closed] entries=28 agents=2
```

### close

Close a session, optionally archiving it.

```bash
npl-session close [--archive] [--session <id>]
```

| Option | Description |
|--------|-------------|
| `--archive` | Move session to `.npl/sessions/archive/` |
| `--session` | Target session (default: current) |

**Behavior:**
- Updates `meta.json` with `status: closed` and `closed` timestamp
- If `--archive`, moves session directory to archive subdirectory
- Clears `.npl/current-session` if closing the current session

```bash
$ npl-session close
Session 2025-12-10 closed

$ npl-session close --archive
Session 2025-12-10 archived
```

## Cursor Tracking

Cursors enable incremental reads. Each agent has its own cursor file:

```
.npl/sessions/<session-id>/.cursors/<agent-id>.cursor
```

Cursor file contents:
```json
{"last_seq": 42, "last_read": "2025-12-10T08:05:00+00:00"}
```

**Read behavior:**
1. Load cursor for agent (default `last_seq: 0` if missing)
2. Return entries where `entry.seq > last_seq`
3. Update cursor to highest seq returned (unless `--peek`)

**Use cases:**
- Primary agent polls for sub-agent updates
- Multiple agents coordinate without reading duplicate entries
- `--peek` allows inspection without affecting cursor state

## Concurrency

The worklog uses `fcntl.LOCK_EX` file locking for atomic appends:
- Multiple agents can write simultaneously without corruption
- Sequence numbers are assigned atomically during lock
- Reads do not require locks (append-only log)

## Integration Patterns

### Parent-Child Agent Communication

```bash
# Parent initializes session
npl-session init --task="Refactor auth module"

# Parent logs task assignment
npl-session log --agent=orchestrator-001 --type=Orchestrator \
    --action=task_assigned --summary="Assigned exploration to explore-auth-001" \
    --data='{"assignee":"explore-auth-001","scope":"src/auth/"}'

# Child agent logs findings
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=analysis --summary="Found 3 files needing refactor" \
    --data='{"files":["auth.ts","session.ts","token.ts"]}'

# Parent reads updates
npl-session read --agent=orchestrator-001 --json
```

### Real-Time Monitoring

```bash
# Watch worklog in real-time
tail -F .npl/sessions/$(npl-session current)/worklog.jsonl

# With jq formatting
tail -F .npl/sessions/$(npl-session current)/worklog.jsonl | jq '.'
```

### Scripted Workflows

```bash
#!/bin/bash
SESSION=$(npl-session init --task="$1")

# Run exploration phase
./run-explorer.sh "$SESSION"

# Check for errors
if npl-session read --agent=checker --json | jq -e '.[] | select(.action=="error")' > /dev/null; then
    echo "Errors found in session $SESSION"
    exit 1
fi

npl-session close --archive
```

## Agent ID Convention

Recommended format: `<agent-type>-<task-slug>-<NNN>`

| Component | Description | Example |
|-----------|-------------|---------|
| `agent-type` | Template/role name (lowercase) | `explore`, `plan`, `code` |
| `task-slug` | Short task identifier | `auth`, `api-refactor` |
| `NNN` | Instance number (zero-padded) | `001`, `002` |

Examples:
- `explore-auth-001`
- `plan-api-refactor-001`
- `code-user-model-003`
- `review-pr-42-001`

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (no active session, session not found, invalid arguments) |

## Environment

| Variable | Default | Description |
|----------|---------|-------------|
| (none) | `.npl/sessions` | Session storage directory |
| (none) | `.npl/current-session` | Current session pointer file |

Paths are relative to current working directory. Run from project root for consistent behavior.

## Limitations

- No built-in filtering for `read` (filter with `jq` or `--json` output)
- No remote/distributed session support (local filesystem only)
- No automatic session expiration or cleanup
- `refs` field accepted but not validated or indexed
- Session IDs cannot contain path separators

## Files Reference

| Path | Purpose |
|------|---------|
| `.npl/sessions/` | Session storage root |
| `.npl/sessions/<id>/meta.json` | Session metadata |
| `.npl/sessions/<id>/worklog.jsonl` | Append-only entry log |
| `.npl/sessions/<id>/.cursors/` | Per-agent cursor files |
| `.npl/sessions/<id>/tmp/` | Temporary file storage |
| `.npl/sessions/archive/` | Archived sessions |
| `.npl/current-session` | Current session ID pointer |

## See Also

- [npl-session.md](./npl-session.md) - Quick reference
- `npl/agent.md` - Agent session tracking specifications
