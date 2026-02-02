# npl-session - Persona

**Type**: Script
**Category**: Session Management
**Version**: 1.0.0

## Overview

`npl-session` is the coordination backbone for multi-agent workflows, providing shared append-only worklogs with cursor-based incremental reads. It enables parent agents to delegate tasks to sub-agents while maintaining synchronized visibility of all progress, findings, and errors through a centralized session directory with per-agent read tracking.

## Purpose & Use Cases

- **Parent-child agent communication**: Primary agents delegate tasks and read sub-agent progress without duplicate processing
- **Cross-agent synchronization**: Multiple agents contribute to a shared worklog while independently tracking their own read positions
- **Real-time workflow monitoring**: Administrators and monitoring tools tail session logs for live visibility
- **Session lifecycle management**: Initialize, track, and archive work sessions tied to specific tasks or features
- **Distributed debugging**: Agents log errors, findings, and decisions to a centralized audit trail

## Key Features

✅ **Cursor-based incremental reads** - Each agent maintains independent read position for efficient polling
✅ **Atomic append-only log** - File locking ensures race-free concurrent writes from multiple agents
✅ **Structured JSONL worklog** - Machine-parseable entries with timestamps, sequences, and typed payloads
✅ **Session metadata tracking** - Status, task descriptions, agent lists, and activity timestamps
✅ **Flexible session lifecycle** - Create, resume, close, and archive sessions with automatic current-session pointer
✅ **Zero-configuration defaults** - Auto-creates sessions when logging if none exists

## Usage

```bash
# Initialize session
npl-session init --task="Implement user authentication"

# Sub-agent logs findings
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found 3 auth files" \
    --data='{"files":["auth.ts","session.ts","token.ts"]}'

# Parent reads new entries
npl-session read --agent=orchestrator-001
# [1] 2025-12-10T08:01:30Z explore-auth-001: file_found - Found 3 auth files

# Check session status
npl-session status --json

# Close and archive when complete
npl-session close --archive
```

Typical workflow: Parent initializes session, delegates to sub-agents who log progress, parent polls for updates via cursor reads, session closes when task completes.

## Integration Points

- **Triggered by**: Parent agents when entering TDD workflows, orchestration tasks, or multi-step explorations
- **Feeds to**: Monitoring dashboards (`tail -F worklog.jsonl`), parent agent coordination loops, session summaries
- **Complements**: `npl-persona` (persona journals reference session logs), TDD agents (test/code cycles logged per session), `dump-files` (session artifacts)

## Parameters / Configuration

- **`--id <session-id>`** - Custom session identifier (default: `YYYY-MM-DD` date-based)
- **`--task <description>`** - Human-readable task stored in session metadata
- **`--agent <agent-id>`** - Unique identifier following `<type>-<task>-<NNN>` convention
- **`--action <type>`** - Action type (e.g., `file_found`, `error`, `task_complete`)
- **`--data <json>`** - Structured payload for machine consumption
- **`--peek`** - Read without advancing cursor (inspection mode)
- **`--json`** - Output as JSON for programmatic parsing

## Success Criteria

- **Atomic writes verified**: No corrupted entries under concurrent access
- **Cursor isolation maintained**: Multiple readers see different unread entry sets
- **Session lifecycle tracked**: Active sessions closable, archived sessions preserved
- **Monitoring enabled**: Real-time `tail -F` reflects new entries immediately

## Limitations & Constraints

- **Local filesystem only**: No remote or distributed session support
- **No entry filtering**: Use `jq` or `--json` output for complex queries
- **Manual cleanup required**: No automatic session expiration or archival
- **Cursor reset manual**: No built-in "mark all read" or cursor rewind commands

## Related Utilities

- **npl-persona** - Persona journals can reference session IDs for work attribution
- **npl-load** - Agent definitions loaded at session start
- **TDD agent scripts** - Log test runs, code changes, and errors to session worklog
- **dump-files** - Captures session artifacts for archival
