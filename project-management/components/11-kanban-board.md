# Kanban Board

| Field | Value |
|-------|-------|
| **ID** | `kanban-board` |
| **Category** | Navigation & Layout |
| **Used In** | 25-Agent Dashboard |

## Description

5-column board (Queued/In Progress/In Review/Done/Rejected) displaying story cards with real-time position updates. Cards show AC progress and can be filtered.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Horizontal scrolling columns on mobile |
| **Full Page** | All columns visible with vertical scroll within columns |

## Props / Configuration

- `columns` — Array of {id, title, cards}
- `cards` — Array of {storyId, title, acProgress, priority, assignedAgent}
- `filters` — Active filter criteria
- `realTimeUpdates` — Boolean (WebSocket connection)

## Interactions

- Cards move between columns as agent status changes (real-time)
- Filter chips narrow visible cards by priority/agent/tag
- Click card → navigates to story detail in Agent Development
- Column counters show card count
