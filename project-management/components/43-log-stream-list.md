# Log Stream List

| Field | Value |
|-------|-------|
| **ID** | `log-stream-list` |
| **Category** | Tables & Lists |
| **Used In** | 09-Execution Progress Panel, 10-Execution Log Viewer |

## Description

Virtualized scrollable list of timestamped log entries with severity-coded rows, expandable JSON payloads, and optional live-tail mode. Supports large log volumes through virtualization and provides export functionality for offline analysis.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Condensed progress event list with timestamp, severity icon, and single-line message |
| **Expanded** | Full log viewer with severity filter controls, expandable JSON cells, live-tail toggle, and export button |

## Props / Configuration

- `entries` — array of log entry objects (`id`, `timestamp`, `severity`, `message`, `payload`)
- `severityFilter` — active severity level filter (`all` | `debug` | `info` | `warn` | `error`)
- `liveMode` — boolean enabling live-tail (new entries appended in real time)
- `autoScroll` — boolean controlling whether the list scrolls to the newest entry automatically
- `onExport` — callback invoked to export the current log view
- `pageSize` — number of entries rendered per virtual page
- `expandJson` — boolean controlling whether JSON payloads are expanded by default

## Interactions

- Scrolling up pauses auto-scroll; a "Jump to latest" button reactivates it
- Clicking a log entry with a JSON payload expands an inline JSON viewer with syntax highlighting
- Severity filter controls update the visible entry set
- Toggle auto-scroll button switches between following latest entries and free scroll
- Export button calls `onExport` to download or copy log data
