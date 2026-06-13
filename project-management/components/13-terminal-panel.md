# Terminal Panel

| Field | Value |
|-------|-------|
| **ID** | `terminal-panel` |
| **Category** | AI-Specific |
| **Used In** | 25-Agent Dashboard, 28-Deploy |

## Description

Terminal output display showing agent commands (install, test, lint) or deploy logs with live stdout/stderr streaming. Syntax-highlighted with error/warning detection.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed to last N lines with expand |
| **Expanded** | Full scrollable terminal output |

## Props / Configuration

- `stream` — WebSocket/SSE connection
- `highlightErrors` — Boolean (red highlighting for stderr/errors)
- `timestamps` — Boolean
- `maxLines` — Buffer limit

## Interactions

- Auto-scrolls to bottom (toggle-able)
- Error lines highlighted in red, warnings in yellow
- Copy-to-clipboard for full output or selection
- Clear button resets display
