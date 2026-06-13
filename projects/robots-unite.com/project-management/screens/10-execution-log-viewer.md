# Execution Log Viewer

| Field | Value |
|-------|-------|
| **ID** | `execution-log-viewer` |
| **Type** | Modal |
| **Category** | Task Execution |
| **User Stories** | US-039 |

## Description

Dedicated viewer for structured execution logs with filtering, pagination, and export capabilities. Supports both historical completed logs and live streaming tail view.

## Key Components

- **Log stream display** — Chronological log entries with timestamps and severity colors (US-039)
- **Severity filters** — checkboxes/tabs for info, warning, error levels
- **JSON expanders** — Clickable entries with structured JSON payloads showing formatted detail panels
- **Pagination controls** — Next/Previous navigation for logs exceeding 10,000 lines (500 lines per page)
- **Line range indicator** — Current page position display (e.g., "Lines 501-1000 of 5342")
- **Live tail mode** — Last 200 lines for running executions with auto-scroll
- **Export button** — Download full log as UTF-8 plain text file

## Interactions

- Severity filter toggling with immediate re-rendering
- Click JSON entry to expand/collapse formatted detail
- Pagination for large log files
- Auto-scroll in live tail mode (toggleable)
- Export downloads entire log regardless of current pagination

## Navigation

- Accessible from: Task Detail page Execution tab "View Logs" link
- Links to: Task Detail page (close modal)