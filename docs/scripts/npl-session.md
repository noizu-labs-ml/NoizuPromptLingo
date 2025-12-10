# npl-session

Session and worklog management for cross-agent communication.

## Synopsis

```bash
npl-session <command> [options]
```

## Description

`npl-session` provides shared worklogs for parent/sub-agent communication. Agents append entries to a JSONL log and read new entries via cursor-based reads.

## Commands

| Command | Purpose |
|---------|---------|
| `init [--id=X] [--task=X]` | Create new session |
| `current` | Get current session ID |
| `log --agent=X --action=Y --summary="..."` | Append worklog entry |
| `read --agent=X [--peek] [--since=N]` | Read new entries since cursor |
| `status [--json]` | Show session stats |
| `list [--all] [--json]` | List sessions |
| `close [--archive]` | Close session |

## Quick Start

```bash
# Initialize session
npl-session init --task="Implement auth"

# Log an entry
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found auth.ts"

# Read new entries
npl-session read --agent=primary
# [1] 2025-12-10T08:01:30Z explore-auth-001: file_found - Found auth.ts

# Check status
npl-session status

# Close when done
npl-session close --archive
```

## Session Directory

```
.npl/sessions/<session-id>/
├── meta.json           # Session metadata
├── worklog.jsonl       # Shared entry log
├── .cursors/           # Per-agent read cursors
└── tmp/                # Temporary files
```

## Worklog Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `seq` | auto | Sequence number |
| `ts` | auto | ISO 8601 timestamp |
| `agent_id` | yes | Agent identifier |
| `agent_type` | yes | Agent template type |
| `action` | yes | Action type |
| `summary` | yes | Human-readable summary |
| `data` | no | JSON payload |
| `tags` | no | Categorization tags |

See [Worklog Entry Schema](./npl-session.detailed.md#worklog-entry-schema) for complete field documentation.

## Agent ID Format

`<agent-type>-<task-slug>-<NNN>`

Examples: `explore-auth-001`, `plan-api-002`, `code-user-model-003`

## Common Options

| Option | Commands | Description |
|--------|----------|-------------|
| `--session` | log, read, status, close | Target specific session |
| `--json` | read, status, list | Output as JSON |
| `--peek` | read | Read without updating cursor |

## Real-Time Monitoring

```bash
tail -F .npl/sessions/$(npl-session current)/worklog.jsonl | jq '.'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |

## See Also

- [npl-session.detailed.md](./npl-session.detailed.md) - Complete reference
  - [Command Reference](./npl-session.detailed.md#command-reference) - All options for each command
  - [Cursor Tracking](./npl-session.detailed.md#cursor-tracking) - How incremental reads work
  - [Integration Patterns](./npl-session.detailed.md#integration-patterns) - Parent-child communication examples
  - [Limitations](./npl-session.detailed.md#limitations) - Known constraints
