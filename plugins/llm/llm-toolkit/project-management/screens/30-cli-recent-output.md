# 30: CLI Recent (command output)

| Field | Value |
|-------|-------|
| ID | SCR-30 |
| Surface | cli-command |
| Type | primary |
| Category | Core |
| Route / Entry | `llm-toolkit recent [--json] [--full] [--limit N] [<period>]` |
| Primary Personas | P-001 |
| User Stories | US-059 |

## Description
One-shot, non-Ink command that reads recent Claude Code sessions directly from the local SQLite-backed store (`better-sqlite3`) and prints them — no API server round-trip. Default window is the last hour; supports a configurable period, result limit, full-content mode, and machine-readable JSON output for scripting.

## Entry Points
- `llm-toolkit recent` from any shell
- Handled specially in `bin.ts` — does not go through the Ink `App` router or `ensureApi()`, so it works even if the API server isn't running

## Key Components
- Plain stdout table/list renderer (session id, title, directory, runner/source, started/updated timestamps, message count, first/last-message preview truncated to 240 chars)
- JSON output mode (`--json`) — structured array for piping into other tools

## States
- **Empty:** no sessions found in the requested period → explicit "no recent sessions" message, not a blank exit
- **Error:** local DB unreadable/locked → clear error to stderr, non-zero exit code

## Interactions
- `--json` switches output format entirely (for scripting/composition, e.g. `| jq`)
- `--full` disables the 240-char preview truncation
- `--limit` caps result count (default 50, max 1000)
- Bare `<period>` argument (e.g. `2h`, `1d`) overrides the default 1-hour window

## Navigation
- **From:** shell invocation
- **To:** n/a (prints and exits); a returned session id can be passed to `llm-toolkit show <id>` (SCR-33)
