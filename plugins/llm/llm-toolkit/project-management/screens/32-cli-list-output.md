# 32: CLI List (command output)

| Field | Value |
|-------|-------|
| ID | SCR-32 |
| Surface | cli-command |
| Type | primary |
| Category | Core |
| Route / Entry | `llm-toolkit list [--project <path>] [--limit N]` |
| Primary Personas | P-001, P-005 |
| User Stories | US-070 |

## Description
One-shot Ink command that lists conversations (optionally scoped to a project) sorted by most-recently-updated — a flat, scriptable equivalent of Browse/Explore for quick shell use.

## Entry Points
- `llm-toolkit list` from any shell

## Key Components
- Row list renderer — title, project path, message count, updated date

## States
- **Loading:** brief inline loading indicator
- **Empty:** "No conversations found" message
- **Error:** API error surfaced inline with status code

## Interactions
- `--project` filters to one project path
- `--limit` caps result count (default 20)

## Navigation
- **From:** shell invocation
- **To:** n/a (prints and exits); id feeds `llm-toolkit show <id>` (SCR-33)
