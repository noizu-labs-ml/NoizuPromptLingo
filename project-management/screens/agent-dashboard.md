---
id: screen-agent-dashboard
title: "Agent Dashboard"
route: /agents/dashboard
personas: [persona-the-archivist, persona-the-guardian]
priority: must-have
---

# Agent Dashboard

## Purpose
Overview of all 8 synthetic agents operating the memory system. Provides at-a-glance health, status, emotional state, and key performance metrics for each agent. This is the operator's primary window into the system's "nervous system" — are agents healthy, are any stressed, is the formation pipeline flowing.

## Layout

```
+------------------------------------------------------------------+
|  System Health Banner                                              |
|  Pipeline: [●] Healthy | Memories/hr: 142 | Avg latency: 87ms   |
|  Active alerts: 2 | Last consolidation: 14 min ago                |
+------------------------------------------------------------------+
|                                                                    |
|  Agent Grid (2 rows x 4 columns)                                  |
|                                                                    |
|  +----------------+  +----------------+  +----------------+  +----+
|  | AgentStatusTile|  | AgentStatusTile|  | AgentStatusTile|  | AST|
|  | Monitor        |  | Archivist      |  | Guardian       |  | Wea|
|  | ● Online       |  | ● Online       |  | ● Online       |  | ● O|
|  | Mood: calm     |  | Mood: alert    |  | Mood: watchful |  | Moo|
|  | Events/hr: 340 |  | Memories/hr:142|  | Blocked: 3     |  | Lin|
|  +----------------+  +----------------+  +----------------+  +----+
|                                                                    |
|  +----------------+  +----------------+  +----------------+  +----+
|  | AgentStatusTile|  | AgentStatusTile|  | AgentStatusTile|  | AST|
|  | Curator        |  | Dreamer        |  | Sentinel       |  | Rec|
|  | ● Online       |  | ● Consolidating|  | ● Online       |  | ● O|
|  | Pruned today: 8|  | Merging: 3     |  | Denials: 0     |  | Rec|
|  | Decay queue: 45|  | Proposals: 12  |  | Compartments: 5|  | Avg|
|  +----------------+  +----------------+  +----------------+  +----+
|                                                                    |
+------------------------------------------------------------------+
|  Recent Activity Feed (collapsible)                               |
|  14:23  Archivist stored memory m-abc123 (domain: debugging)      |
|  14:22  Weaver created 4 associations for m-abc123                |
|  14:20  Guardian quarantined m-xyz789 (contradiction detected)    |
|  14:18  Curator pruned 3 decayed memories                          |
|  14:15  Dreamer consolidated 5 memories into m-new456             |
|  [Show more...]                                                    |
+------------------------------------------------------------------+
```

## Key Components
- **System Health Banner**: Top-level system health. Pipeline status (healthy/degraded/down), throughput (memories formed per hour), average formation latency, active alert count, time since last consolidation run.
- **Agent Grid** (uses `component-agent-status-tile`): 2x4 grid of agent tiles. Each tile shows agent name, status indicator (online/busy/error/offline), current emotional state label, and one key metric specific to that agent. Tiles are ordered by pipeline position: Monitor → Archivist → Guardian → Weaver → Curator → Dreamer → Sentinel → Recall Agent.
- **Recent Activity Feed**: Chronological log of agent actions across the system. Each entry shows timestamp, agent name (color-coded), action description, and relevant memory ID (clickable). Collapsible, auto-refreshes via WebSocket.

## Interactions
- **Click agent tile** → Navigate to `/agents/:id` for that agent's detail view
- **Click memory ID in activity feed** → Navigate to `/memories/:id`
- **Click alert count in health banner** → Navigate to `/guardian/alerts`
- **Hover agent tile** → Expand to show emotional state radar chart preview and secondary metrics
- **Toggle activity feed** → Collapse/expand the recent activity section
- **Health banner pipeline status click** → Show pipeline health breakdown (per-stage latency, queue depths)

## Data Requirements
- `GET /api/v1/agents` — All agents with current state, status, key metrics
- `GET /api/v1/admin/health` — System-level health metrics
- WebSocket subscription: `agent.state_changed`, `memory.stored`, `memory.quarantined`, `memory.pruned`, `association.created`, `memory.consolidated` — for real-time activity feed
- Activity feed: `GET /api/v1/admin/activity?limit=20` with cursor pagination

## States
- **Empty state**: All agent tiles show "Initializing..." with grey status indicators. Activity feed empty with "Waiting for first event..."
- **Loading state**: Skeleton tiles in the grid. Health banner shows loading shimmer.
- **Degraded state**: Affected agent tiles turn amber. Health banner changes to "Degraded" with affected pipeline stages highlighted. Activity feed filters to show only error/warning events by default.
- **Error state**: Failed agent tiles turn red with error message. Health banner shows "Pipeline Down" if critical agents (Archivist, Guardian) are affected.
