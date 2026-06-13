# Status Badge

| Field | Value |
|-------|-------|
| **ID** | `status-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 01-Script List, 06-Agent List, 08-Run List, 09-Run Detail, 10-Run Diff, 16-Review Queue, 30-Batch Run Dashboard |

## Description

Color-coded badge indicating the current state of an entity. Used for run status (pending/running/completed/failed/cancelled), verdicts (PASS/WARN/FAIL), health states (green/amber/red/gray), and publication status (draft/published/archived).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small pill within a table cell or header line |
| **Expanded** | Large hero badge at the top of a detail view (e.g., verdict badge on Run Detail) |

## Props / Configuration

- `status` — The status value (maps to color scheme)
- `variant` — `inline` | `hero`
- `tooltip` — Optional tooltip with extra context (e.g., last health check time, failure reason)
- `colorScheme` — Map of status values to colors (green/amber/red/gray/blue)

## Interactions

- Hover to show tooltip with additional context
- Static display (no click action on its own)
