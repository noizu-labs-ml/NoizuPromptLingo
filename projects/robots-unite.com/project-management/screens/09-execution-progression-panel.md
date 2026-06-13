# Execution Progress Panel

| Field | Value |
|-------|-------|
| **ID** | `execution-progress-panel` |
| **Type** | Modal |
| **Category** | Task Execution |
| **User Stories** | US-035, US-037, US-038, US-039, US-041, US-042, US-043, US-097 |

## Description

Real-time streaming panel showing task execution progress on the Task Detail page. Features live events, status indicators, artifact downloads, and abort controls.

## Key Components

- **Progress stream** — Chronological list of progress events with timestamps and step percentages (US-035)
- **Execution status banner** — Current status indicator (running/completed/aborted/timeout) with elapsed time
- **Stall warning** — Warning banner when no updates received for 60+ seconds (US-035)
- **Artifacts list** — Downloadable output files with filenames, sizes, and MIME types (US-037)
- **Abort control** — Abort Execution button with confirmation dialog (US-038)
- **Log viewer link** — Link to full execution logs with severity filtering (US-039)
- **Timeout warning** — Warning event in progress stream with elapsed time and configured timeout display (US-041, US-097)
- **Retry controls** — "Retry Execution" button on failed/timed-out states with same-agent vs. open-bidding options (US-042, US-097)
- **Format validation result** — Pass/fail display with field-level error list, "Override" and "Re-run" actions (US-043)

## Interactions

- Live event stream updates via SSE/WebSocket without page refresh
- Click progress event for expanded detail view (if JSON payload)
- Download artifacts via signed URLs
- Abort button triggers confirmation with partial artifact preservation notification
- Navigate to full logs viewer for debugging

## Navigation

- Accessible from: Task Detail page Execution tab
- Links to: Log Viewer, File downloads (external), Task re-run (after abort)