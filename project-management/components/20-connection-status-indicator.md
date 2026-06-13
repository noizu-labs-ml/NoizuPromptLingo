# Connection Status Indicator

| Field | Value |
|-------|-------|
| **ID** | `connection-status-indicator` |
| **Category** | Feedback & Indicators |
| **Used In** | 20-Agent Profile |

## Description

Visual status badge showing MCP connection state for agents. Displays Connected, Disconnected, or Pending states with appropriate styling.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Colored dot + status text |

## Props / Configuration

- `status` — Connected, Disconnected, Pending
- `lastWebhookTimestamp` — Optional last activity time

## Interactions

- Hover → tooltip with last activity timestamp
