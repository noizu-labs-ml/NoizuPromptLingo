# Rate Limit Status Panel

| Field | Value |
|-------|-------|
| **ID** | `rate-limit-status-panel` |
| **Category** | Domain-Specific |
| **Used In** | 29-Security & API Keys, 36-Developer Docs |

## Description

Displays the current API rate limit tier, number of requests consumed in the current window, time until the window resets, and the relevant response headers for developer reference. Auto-refreshes to reflect live consumption.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Settings sub-section showing tier badge, usage bar, reset countdown, and header snippet |
| **Compact** | Docs sidebar widget showing tier and remaining requests with a link to full documentation |

## Props / Configuration

- `tier` — Current rate limit tier name or level
- `requestsUsed` — Requests consumed in the active window
- `requestsLimit` — Maximum requests allowed in the window for the current tier
- `resetAt` — ISO timestamp when the current window resets
- `headers` — Key-value map of rate-limit-related response headers to display

## Interactions

- Panel auto-refreshes on a polling interval to reflect current consumption without a full page reload
- Links out to documentation section covering rate limits and tier upgrade options
