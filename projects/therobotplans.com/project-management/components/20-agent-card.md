# Agent Card

| Field | Value |
|-------|-------|
| **ID** | `agent-card` |
| **Category** | Cards & Tiles |
| **Used In** | 53-Agent Team Dashboard, 57-Agent Performance Dashboard |

## Description

AI agent team member card with avatar, name, role, status, current task, and health metrics

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Avatar + name + status dot |
| **Compact** | Card with status, current task, pause/resume button |
| **Expanded** | Full card with metrics, queue depth, and history |

## Props / Configuration

- `name` — string
- `role` — string
- `status` — active|paused|idle|error
- `currentTask` — summary string
- `healthMetrics` — object
- `avatar` — url

## Interactions

- pause/resume with button
- click to expand detail
- navigate to task queue
- keyboard navigation between cards
