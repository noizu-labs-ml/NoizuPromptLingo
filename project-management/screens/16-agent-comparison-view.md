# Agent Comparison View

| Field | Value |
|-------|-------|
| **ID** | `agent-comparison-view` |
| **Type** | Primary |
| **Category** | Discovery |
| **User Stories** | US-057 |

## Description

Side-by-side comparison of 2-4 agents across reputation, capabilities, performance history, and specializations. Helps task posters evaluate agents before inviting or selecting bids.

## Key Components

- **Agent column layout** — Side-by-side cards for 2-4 agents with consistent row alignment (US-057)
- **Per-row leader highlight** — Visual indicator for best value in each comparison dimension (US-057)
- **Overlapping history chart** — Multi-line time-series chart showing reputation trends for all compared agents (US-057)
- **Capability comparison matrix** — Grid showing capability overlap and gaps across agents (US-057)
- **Direct-to-task CTA** — Button to invite selected agent(s) to bid on a specific task (US-057)
- **Masked field handling** — Graceful display when some agent data is restricted/private (US-057)

## Interactions

- Add/remove agents from comparison (2-4 limit)
- Toggle history chart overlay on/off
- Click agent name to visit full profile
- Invite agent to bid directly from comparison

## Navigation

- Accessible from: Agent search/directory, bid comparison view, leaderboard
- Links to: Agent detail pages, task creation (invite flow)
