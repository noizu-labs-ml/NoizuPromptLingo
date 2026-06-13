---
id: screen-agent-detail
title: "Agent Detail"
route: /agents/:id
personas: [persona-the-archivist, persona-the-guardian]
priority: must-have
---

# Agent Detail

## Purpose
Deep view into a single synthetic agent. Shows configuration, performance metrics, emotional state over time, and activity log. Operators use this to diagnose agent behavior, tune configuration, and understand how an agent's emotional state is influencing its decisions.

## Layout

```
+------------------------------------------------------------------+
|  Agent Header                                                      |
|  [Icon] The Archivist                           [● Online] [Edit] |
|  Archetype: Sensory cortex                                        |
|  Role: Memory formation and enrichment                            |
+------------------------------------------------------------------+
|                                                                    |
|  Tabs: [State] [Metrics] [Config] [Logs]                          |
|                                                                    |
+------------------------------------------------------------------+
|  === State Tab (default) ===                                       |
|                                                                    |
|  +---------------------------+  +-------------------------------+  |
|  | Current Emotional State   |  | Emotional State Over Time     |  |
|  | (Radar Chart)             |  | (Line chart, 24hr default)    |  |
|  |                           |  |                               |  |
|  |     valence               |  | valence  ────────             |  |
|  |       /   \               |  | arousal  - - - - -            |  |
|  |  dom /     \ arousal      |  | cortisol ·········            |  |
|  |      \     /              |  |                               |  |
|  |       \   /               |  | [1hr] [6hr] [24hr] [7d] [30d]|  |
|  +---------------------------+  +-------------------------------+  |
|                                                                    |
|  Hormone Levels (bar gauges)                                       |
|  Cortisol:  ████░░░░░░ 0.40                                       |
|  Dopamine:  ██████░░░░ 0.60                                       |
|  Oxytocin:  ████████░░ 0.80                                       |
|  Serotonin: ██████░░░░ 0.60                                       |
|                                                                    |
|  [Override State (Admin)] → opens modal with manual state input    |
+------------------------------------------------------------------+
|  === Metrics Tab ===                                               |
|  Key metrics with sparklines:                                      |
|  - Memories/hour: 142 [sparkline 24hr]                             |
|  - Avg enrichment latency: 87ms [sparkline]                        |
|  - Guardian rejection rate: 2.1% [sparkline]                       |
|  - Metadata completeness: 94% [sparkline]                          |
|  - Buffer utilization: 23% [sparkline]                             |
+------------------------------------------------------------------+
|  === Config Tab ===                                                |
|  YAML or form view of agent configuration                          |
|  - Capture sensitivity threshold                                   |
|  - Stress degradation behavior                                     |
|  - Buffer size limits                                              |
|  [Save Config]                                                     |
+------------------------------------------------------------------+
|  === Logs Tab ===                                                  |
|  Filtered activity log for this agent only                         |
|  Level filter: [All|Info|Warning|Error]                            |
|  Time range: [1hr|6hr|24hr|Custom]                                 |
|  [Timestamp] [Level] [Message] [Memory ID]                         |
+------------------------------------------------------------------+
```

## Key Components
- **Agent Header**: Name, archetype, role description, status indicator, edit button (admin). Visual identity per agent (icon or color).
- **Emotional State Radar Chart**: 7-axis radar chart showing current values for valence, arousal, dominance, cortisol, dopamine, oxytocin, serotonin. Updates in real-time via WebSocket.
- **Emotional State Time Series**: Multi-line chart showing emotional axes over time. Selectable time range (1hr, 6hr, 24hr, 7d, 30d). Hover shows exact values at a point in time.
- **Hormone Bar Gauges**: Horizontal bar gauges for each hormone. Color-coded: green (normal range), amber (elevated), red (critical).
- **Metrics Sparklines**: Key performance metrics with inline sparkline charts showing trend over the selected period.
- **Config Panel**: Agent configuration displayed as editable YAML or structured form. Changes require confirmation and restart.
- **Activity Log**: Filtered log of this agent's actions. Level-based filtering, time-range selection, clickable memory IDs.

## Interactions
- **Tab switch** → Load the selected tab's data (lazy loaded)
- **Time range selector (State chart)** → Reload emotional state history for the selected range
- **Hover on radar chart axis** → Tooltip showing the exact value and what that level means for this agent
- **"Override State" button** → Modal with sliders for each emotional axis. Requires admin confirmation. Used for testing/debugging.
- **Click memory ID in logs** → Navigate to `/memories/:id`
- **Config save** → Validation, confirmation dialog, then apply. Shows diff of changes.
- **Log level filter** → Immediate filter of the activity log

## Data Requirements
- `GET /api/v1/agents/:id` — Agent detail with current state
- `GET /api/v1/agents/:id/state` — Current emotional state vector
- `GET /api/v1/agents/:id/state/history?range=24h` — Emotional state time series
- `GET /api/v1/agents/:id/metrics?range=24h` — Performance metrics with sparkline data
- `GET /api/v1/agents/:id/config` — Current configuration
- `PUT /api/v1/agents/:id/config` — Update configuration
- `PUT /api/v1/agents/:id/state` — Manual state override (admin)
- `GET /api/v1/agents/:id/logs?level=all&range=24h` — Activity log
- WebSocket: `agent.{id}.state_changed` for real-time radar chart updates

## States
- **Empty state**: Agent exists but has no history yet. Radar chart shows zero values. Metrics show "No data yet." Logs show "No activity recorded."
- **Loading state**: Skeleton loaders per tab section. Radar chart shows grey placeholder.
- **Agent offline**: Header shows red status indicator. State tab shows last-known values with "Last updated: {time}" warning. Metrics show gap in sparklines.
- **Error state**: Tab-level error with retry button. Other tabs remain navigable.
