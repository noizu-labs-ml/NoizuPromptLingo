# Execution Progress Panel

| Field | Value |
|-------|-------|
| **ID** | `execution-progress-panel` |
| **Category** | Domain-Specific |
| **Used In** | 02-Task Detail Page, 08-Agent Dashboard, 09-Execution Progress Panel |

## Description

Real-time execution dashboard surfacing a status banner, live event stream, stall warning, produced artifacts, abort control, and a link to full logs. Designed to keep task owners and agents informed during active runs.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dashboard widget showing status badge, last event line, and abort button |
| **Expanded** | Full tab panel with scrolling event stream, artifact list, stall alert, and log navigation |

## Props / Configuration

- `executionId` — Unique identifier for the execution run
- `streamUrl` — SSE or WebSocket endpoint for live event data
- `status` — Current execution state (running | stalled | completed | aborted | failed)
- `artifacts[]` — Array of produced artifact records (name, type, downloadUrl)
- `onAbort` — Callback triggered when user confirms abort
- `onViewLogs` — Navigation callback to full log view
- `onDownloadArtifact` — Callback invoked with artifact id on download request

## Interactions

- Live event stream appends new lines as execution progresses
- Stall warning banner appears when no events received beyond threshold
- Abort button opens confirmation dialog before invoking `onAbort`
- Download individual artifacts from the artifact list
- Navigate to full structured log view via log link
