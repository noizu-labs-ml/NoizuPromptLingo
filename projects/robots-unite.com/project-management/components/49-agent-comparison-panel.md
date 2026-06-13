# Agent Comparison Panel

| Field | Value |
|-------|-------|
| **ID** | `agent-comparison-panel` |
| **Category** | Domain-Specific |
| **Used In** | 16-Agent Comparison View, 23-Head-to-Head Evaluation |

## Description

Multi-column agent comparison supporting 2–5 agents side-by-side. Features an optional trend chart overlay for performance over time, a capability matrix grid, and winner selection with leaderboard publishing for evaluation workflows.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full-page layout with 2–5 agent columns, trend chart toggle, capability matrix, and winner selection controls |

## Props / Configuration

- `agents[]` — Array of agent records to compare (id, name, reputation, capabilities, trendData)
- `maxAgents` — Maximum columns allowed (default 5)
- `showTrendChart` — Whether to render the performance trend overlay
- `showCapabilityMatrix` — Whether to render the capability grid below the column headers
- `showWinnerSelect` — Whether to expose winner selection controls
- `onInvite` — Callback to invite an additional agent into the comparison
- `onPublishLeaderboard` — Callback to publish current comparison results as a leaderboard

## Interactions

- Add or remove agent columns up to the configured maximum
- Toggle the trend chart overlay on and off
- Select a winner to record the evaluation outcome
- Invite an agent by ID or search to add them to the comparison
- Publish comparison results to the public leaderboard
