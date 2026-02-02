# FR-003: npl-session Worklog Coordinator

**Status**: Draft

## Description

Implement `npl-session` CLI utility for managing shared worklogs for parent-child agent communication with cursor-based reads.

## Interface

```bash
# Initialize session
npl-session init --task "Implement feature X"

# Log entry
npl-session log --agent explore-001 --action found --summary "Found config in src/"

# Read new entries
npl-session read --agent parent

# Peek without advancing cursor
npl-session read --agent parent --peek

# Get session status
npl-session status

# Close session
npl-session close --summary "Completed implementation"
```

## Behavior

- **Given** session is initialized
- **When** agents log entries
- **Then** entries are appended atomically to worklog.jsonl
- **And** per-agent cursors track read positions
- **And** read operations return only new entries since cursor
- **And** peek operations do not advance cursor

## Worklog Format

```jsonl
{"id":"e1","ts":"2026-02-02T14:00:00Z","agent":"explore-001","action":"start","summary":"Beginning exploration"}
{"id":"e2","ts":"2026-02-02T14:01:00Z","agent":"explore-001","action":"found","summary":"Located main.py","metadata":{"file":"src/main.py"}}
{"id":"e3","ts":"2026-02-02T14:02:00Z","agent":"explore-001","action":"complete","summary":"Finished exploration","outputs":["report.md"]}
```

## Session Storage Structure

```
.npl/sessions/
└── 2026-02-02/
    ├── worklog.jsonl
    ├── .cursors/
    │   ├── parent
    │   └── explore-001
    ├── .summary.md
    └── .detailed.md
```

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `init` | Start new session |
| `log` | Append worklog entry |
| `read` | Read entries since cursor |
| `status` | Show session status |
| `close` | Close session with summary |

## Edge Cases

- **No active session**: Error if log/read without init
- **Concurrent log writes**: Atomic append ensures consistency
- **Cursor corruption**: Reset to beginning if invalid
- **Large worklogs**: Stream reads for efficiency
- **Missing agent cursor**: Initialize to 0 on first read

## Related User Stories

- US-047

## Test Coverage

Expected test count: 15-18 tests
Target coverage: 100% for this FR
