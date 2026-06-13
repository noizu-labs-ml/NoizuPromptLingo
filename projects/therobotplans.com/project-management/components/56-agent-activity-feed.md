# Agent Activity Feed

| Field | Value |
|-------|-------|
| **ID** | `agent-activity-feed` |
| **Category** | AI-Specific Components |
| **Used In** | 01-Today Dashboard, 53-Agent Team Dashboard |

## Description

Real-time feed of AI agent actions with status, current task description, and pause controls

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed feed showing latest entry |
| **Expanded** | Full scrollable feed with filters |

## Props / Configuration

- `entries` — real-time stream
- `agentFilter` — optional agent id
- `showPauseControls` — boolean

## Interactions

- expand/collapse
- filter by agent
- pause/resume agents from feed
- click entry for detail
