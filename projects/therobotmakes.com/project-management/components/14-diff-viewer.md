# Diff Viewer

| Field | Value |
|-------|-------|
| **ID** | `diff-viewer` |
| **Category** | Data Display |
| **Used In** | 24-Agent Development, 25-Agent Dashboard, 27-Review Gate |

## Description

Side-by-side or unified code diff view with syntax highlighting, line numbers, and inline annotation capability. Supports severity badges for code review findings.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Unified diff (single column, +/- lines) |
| **Expanded** | Side-by-side with full context |

## Props / Configuration

- `before` — Original file content
- `after` — Modified file content
- `language` — Syntax highlighting language
- `annotations` — Array of {line, severity, message}
- `mode` — unified | split

## Interactions

- Click line number → adds annotation
- Hover annotation → shows message popup
- Expand/collapse unchanged regions
- Toggle between unified and split view
