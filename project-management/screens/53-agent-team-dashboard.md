# Agent Team Dashboard

| Field | Value |
|-------|-------|
| **ID** | `agent-team-dashboard` |
| **Type** | Dashboard |
| **Category** | Agent Management |
| **User Stories** | US-076, US-081 |

## Description

All active agents displayed as team members with real-time status, current task summary, health metrics, pause/resume controls, and queue depth. Agents are treated as first-class team members.

## Key Components

- **Agent cards** — One card per agent with avatar, name, role
- **Status indicator** — Active/paused/idle/error states
- **Current task summary** — What the agent is working on now
- **Health metrics** — Error rate, task completion rate, response time
- **Pause/resume button** — Immediately pause or resume an agent
- **Uptime badge** — How long the agent has been active
- **Keyboard nav** — Navigate between agent cards
- **Detail panel expand** — Expand for full agent metrics

## Interactions

- Pause/resume agents with one click
- Click card to expand detailed metrics
- View real-time task progress
- Navigate to agent's task queue
- Filter by agent role or status

## Navigation

- Accessible from: Main nav (agents section)
- Links to: Agent Task Queue, Agent Performance, Agent Audit Log, Custom Agent Builder
