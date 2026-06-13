---
id: component-agent-status-tile
name: "Agent Status Tile"
used_in: [screen-agent-dashboard]
---

# Agent Status Tile

## Purpose
A dashboard tile representing a single synthetic agent. Shows the agent's name, current status, emotional disposition, and one key metric. Designed for the 2x4 grid on the Agent Dashboard. Each tile is a portal into that agent's behavior and health.

## Props/Inputs
- `id`: string -- Agent identifier
- `name`: string -- Display name (e.g., "The Archivist")
- `archetype`: string -- Role archetype (e.g., "Sensory cortex")
- `status`: enum (online | busy | degraded | offline | error) -- Current operational status
- `emotionalState`: EmotionalMetadata -- Current emotional state vector
- `moodLabel`: string -- Human-readable mood label (e.g., "alert", "watchful", "consolidating")
- `keyMetric`: { label: string, value: string | number, trend: "up" | "down" | "stable" } -- Primary metric for this agent
- `secondaryMetrics`: array of { label: string, value: string | number } -- Additional metrics (shown on hover)

## Visual Description

```
+----------------------------------+
|  [Icon]  The Archivist           |
|          Sensory cortex          |
|                                  |
|  [●] Online         mood: alert  |
|                                  |
|  Memories/hr:  142  [↑]         |
+----------------------------------+
```

- **Dimensions**: Fixed aspect ratio card, approximately 240px x 160px. Responsive within grid constraints.
- **Agent icon**: Unique icon per agent. Monochrome, 24x24px. Positioned top-left.
- **Status indicator**: Colored circle (dot) next to status text:
  - Online: green
  - Busy: blue (pulsing)
  - Degraded: amber
  - Offline: grey
  - Error: red (pulsing)
- **Mood label**: Italicized, colored to match the emotion badge color mapping for the current valence/arousal.
- **Key metric**: Bold value with label. Small trend arrow (up = green, down = red for most metrics; inverted for metrics where down is good like "rejection rate").
- **Border**: 1px solid grey. Top border 3px solid in the agent's signature color:
  - Monitor: teal
  - Archivist: indigo
  - Guardian: red
  - Weaver: purple
  - Curator: amber
  - Dreamer: violet
  - Sentinel: slate
  - Recall Agent: blue
- **Background**: White, with a very faint background tint matching the agent's signature color (5% opacity).

## Interaction
- **Click**: Navigate to `/agents/:id`
- **Hover**: Expand to show secondary metrics, mini radar chart of current emotional state (7 axes), and a one-line status summary. Expansion is a smooth CSS transition, not a modal.
- **Status indicator click**: If degraded or error, show a tooltip with the last error message and timestamp.
