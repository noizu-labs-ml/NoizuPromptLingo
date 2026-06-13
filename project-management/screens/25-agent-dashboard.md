# Agent Dashboard

| Field | Value |
|-------|-------|
| **ID** | `agent-dashboard` |
| **Type** | Dashboard |
| **Category** | Ink Phase |
| **User Stories** | INK-053, INK-054, INK-055, INK-056 |

## Description

Real-time monitoring dashboard showing agent activity, story progress (Kanban), file changes, and activity log. Auto-updates via WebSocket. Designed to be screenshot-friendly for "build in public" sharing.

## Key Components

- **Agent Status Cards** — Per-agent panel showing current story, file, elapsed time, status (Idle/Working/Waiting) (INK-053)
- **Live Code Diff Stream** — Real-time character/chunk streaming of agent's code output (INK-053)
- **Terminal Output Panel** — Live stdout/stderr from agent commands (install, test, lint) (INK-053)
- **Kanban Board** — 5 columns (Queued/In Progress/In Review/Done/Rejected) with story cards (INK-054)
- **File Tree with Change Indicators** — A/M/D badges (green/yellow/red) with click-to-view (INK-055)
- **Activity Log** — Timestamped entries with error highlighting, filter by agent/story/severity, JSON/CSV export (INK-056)

## Interactions

- Dashboard auto-updates without refresh (WebSocket/SSE)
- Kanban cards show AC progress counter
- File tree click opens file in read-only or editor (depending on agent state)
- Activity log filters narrow by agent, story, or severity
- Error entries expand to show stack trace
- Log exportable as JSON/CSV

## Navigation

- Accessible from: Agent Development toolbar, Dashboard "Continue" on projects in Ink phase
- Links to: Agent Development (click story), File viewer/editor
