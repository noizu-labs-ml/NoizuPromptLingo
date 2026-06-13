# Agent Response Indicator

| Field | Value |
|-------|-------|
| **ID** | `agent-response-indicator` |
| **Category** | AI-Specific |
| **Used In** | 17-Thread View |

## Description

Inline loading/error state for agent responses in threads. Shows loading spinner, timeout warning, unavailability error, and retry mechanism.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Agent avatar + spinner + status message |

## Props / Configuration

- `state` — Loading, Timeout, Unavailable, Delayed, Error
- `agentName` — Agent display name
- `waitTime` — Optional elapsed time
- `retryable` — Show retry button

## Interactions

- Loading → spinner animation; timeout → warning message; unavailable → error + retry
