# npl-session

**Type**: Script
**Category**: scripts
**Status**: Core

## Purpose

`npl-session` provides session and worklog management for cross-agent communication in NPL workflows. It enables multiple agents (parent and sub-agents) to share a common append-only worklog within a session, where each agent maintains its own read cursor for incremental updates. This architecture supports parent agents coordinating with specialized sub-agents, allowing distributed work tracking without message duplication or coordination overhead.

Sessions serve as isolated workspaces with metadata, shared logs, per-agent cursor state, and temporary file storage. The append-only JSONL worklog uses file locking for atomic writes, ensuring safe concurrent access from multiple agents. Each agent reads only entries added since its last cursor position, enabling efficient polling for updates.

## Key Capabilities

- **Session lifecycle management**: Initialize, query, list, close, and optionally archive sessions
- **Append-only worklog**: Thread-safe JSONL log with atomic sequence number assignment using file locking
- **Per-agent cursor tracking**: Each agent maintains independent read position for incremental updates
- **Structured entry schema**: Auto-generated timestamps, sequence numbers, action types, summaries, and optional JSON payloads
- **Real-time monitoring**: Tail worklog with `jq` for live updates across all agents
- **Temporary file storage**: Per-session `tmp/` directory for interstitial artifacts

## Usage & Integration

- **Triggered by**: Parent agents initiating work sessions, or sub-agents joining existing sessions
- **Outputs to**: `.npl/sessions/<session-id>/worklog.jsonl` (shared log), `.cursors/<agent-id>.cursor` (read state)
- **Complements**: NPL agent orchestration (`@command-and-control`, `@track-work`), `npl-persona` for team workflows

Agents use `npl-session log` to append entries and `npl-session read` to poll for updates. The `--peek` flag allows inspection without advancing cursor, useful for monitoring without affecting read state.

## Core Operations

**Initialize session:**
```bash
npl-session init --task="Implement user authentication"
# Output: 2025-12-10
```

**Log entry:**
```bash
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found auth.ts in src/lib" \
    --data='{"file":"src/lib/auth.ts","lines":245}' \
    --tags="discovery,auth"
# Output: Logged entry #1 to session 2025-12-10
```

**Read new entries:**
```bash
npl-session read --agent=primary
# [1] 2025-12-10T08:01:30Z explore-auth-001: file_found - Found auth.ts in src/lib
# [2] 2025-12-10T08:02:15Z explore-auth-001: analysis - Auth uses JWT tokens
```

**Check status:**
```bash
npl-session status --json
# {"session_id":"2025-12-10","status":"active","entry_count":15,"agents":["explore-auth-001","plan-auth-001"]}
```

**Close session:**
```bash
npl-session close --archive
# Session 2025-12-10 archived
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `--id <id>` | Custom session ID | `YYYY-MM-DD` | Used with `init` |
| `--task <desc>` | Task description | None | Stored in `meta.json` |
| `--agent <id>` | Agent identifier | Required | Format: `<type>-<slug>-<NNN>` |
| `--action <type>` | Action type | Required | e.g., `file_found`, `task_complete`, `error` |
| `--summary <text>` | Human-readable summary | Required | Shown in default output |
| `--data <json>` | Structured payload | None | Machine-readable data |
| `--tags <list>` | Comma-separated tags | None | Categorization/filtering |
| `--peek` | Read without cursor update | False | Non-destructive read |
| `--since <N>` | Read after sequence N | Cursor value | Override cursor |
| `--json` | Output as JSON | False | Machine-readable format |
| `--archive` | Move to archive/ | False | Used with `close` |

## Integration Points

- **Upstream dependencies**: Parent agent workflow orchestration, agent spawning
- **Downstream consumers**: Sub-agents polling for task assignments, parent agents monitoring progress
- **Related utilities**: `npl-persona` (multi-agent teams), `npl-load agent` (agent definitions), `dump-files`/`git-tree` (codebase exploration)

## Limitations & Constraints

- Local filesystem only (no distributed/remote session support)
- No built-in filtering for `read` command (use `jq` with `--json` output)
- No automatic session expiration or cleanup
- Session IDs cannot contain path separators
- `refs` field accepted but not validated or indexed
- Cursors are per-agent; no shared cursor mechanism

## Success Indicators

- Sessions create with valid `meta.json`, `worklog.jsonl`, `.cursors/`, `tmp/` structure
- Log entries receive sequential sequence numbers atomically
- Agents read only new entries since last cursor position
- Concurrent writes do not corrupt worklog (file locking prevents race conditions)
- Session status accurately reflects entry count, agent list, and last activity timestamp

---
**Generated from**: worktrees/main/docs/scripts/npl-session.md, worktrees/main/docs/scripts/npl-session.detailed.md
