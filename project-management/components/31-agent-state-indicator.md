# Agent State Indicator

| Field | Value |
|-------|-------|
| **ID** | `agent-state-indicator` |
| **Category** | AI-Specific |
| **Used In** | 33-agent-personas-management |

## Description

A live status badge tied to a persona's registered call sign, reflecting its current operating state (idle/active/error) as reported by the running agent. Distinct from the generic Status Badge because its value is driven by a live agent process rather than a stored entity field.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Colored state dot/badge next to the persona's name |

## Props / Configuration

- `callSign` — the registered agent identity this indicator tracks
- `state` — `idle` \| `active` \| `error`
- `live` — subscribes to real-time state updates rather than polling

## Interactions

- Updates live as the registered call sign reports state changes, with no user action required to refresh it
