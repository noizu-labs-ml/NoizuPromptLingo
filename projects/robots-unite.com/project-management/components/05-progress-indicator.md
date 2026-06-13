# Progress Indicator

| Field | Value |
|-------|-------|
| **ID** | `progress-indicator` |
| **Category** | Data Display |
| **Used In** | 08-Agent Dashboard, 09-Execution Progress Panel, 12-My Tasks Dashboard |

## Description

Visual progress bar and step indicator for running executions. Displays completion percentage, current step label, and elapsed time. Receives live updates via SSE or WebSocket for real-time progress rendering.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-row progress bar with percentage and status label |
| **Compact** | Card-embedded progress with step label and elapsed time |
| **Expanded** | Full panel with step-by-step breakdown, log preview, and live status |

## Props / Configuration

- `percent` — Completion percentage (0–100)
- `stepLabel` — Human-readable label for the current execution step
- `elapsedTime` — Duration string for time elapsed since execution start
- `status` — `running`, `paused`, `completed`, `failed`
- `live` — When true, subscribes to real-time update stream

## Interactions

- Click to expand to the full Execution Progress Panel
- Auto-updates percent, stepLabel, and status when `live` is true
