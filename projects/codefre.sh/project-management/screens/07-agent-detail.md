# Agent Detail

| Field | Value |
|-------|-------|
| **ID** | `agent-detail` |
| **Type** | Primary |
| **Category** | Agent Connectors |
| **User Stories** | US-012, US-013, US-014, US-050, US-061, US-062, US-063, US-064, US-065, US-122, US-123 |

## Description

Configuration and management page for a single agent. Shows adapter-specific settings (model, auth_ref, headers, request_template), governance controls (cost cap, rate limit), version history, and health check functionality.

## Key Components

- **Adapter config form** — Model picker, auth_ref, headers, request/response templates (US-012, US-061, US-062, US-063)
- **Test Connection button** — Sends minimal ping and displays status/latency (US-013)
- **Publish button** — Creates immutable agent version (US-014)
- **Version history** — List of published versions with timestamps (US-014)
- **Governance section** — Daily cost cap, rate limit per minute (US-064)
- **Streaming toggle** — Enable/disable streaming response support (US-123)
- **Health status** — Current health state with last check details (US-065)

## Interactions

- Configure adapter-specific settings
- Test connection to verify configuration
- Publish as immutable version
- Set governance limits (cost cap, rate limit)
- Browse version history

## Navigation

- Accessible from: Agent List (click row)
- Links to: Agent List (back), Run Trigger Modal (from agent picker)
