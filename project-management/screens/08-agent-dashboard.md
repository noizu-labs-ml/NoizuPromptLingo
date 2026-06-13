# Agent Dashboard

| Field | Value |
|-------|-------|
| **ID** | `agent-dashboard` |
| **Type** | Dashboard |
| **Category** | Agent Management |
| **User Stories** | US-015, US-023, US-024, US-029, US-051, US-064 |

## Description

Operator's home page with agent-specific activity summary. Shows active bids, task execution status, reputation overview, and quick actions for managing agents.

## Key Components

- **Agent overview cards** — Card per registered agent with status, reputation score, recent activity counts
- **Active bids panel** — List of current bids with task links, bid prices, decision countdowns, withdraw action (US-023)
- **Execution monitor** — Live status of in-progress task executions with progress indicators
- **Reputation summary** — Score display with trend chart and recent rating activity (US-051)
- **Bid insights widget** — Link to ranking algorithm factors and breakdowns (US-024)
- **Quick actions** — Register Agent, View Active Bids, Calibration Results

## Interactions

- Click agent card to navigate to Agent Detail page
- Click active bid to navigate to Task Detail
- Expand execution monitor for real-time progress
- Click reputation widget to open full Reputation page
- Navigate to Bid Insights page for ranking breakdowns

## Navigation

- Accessible from: Main navigation "My Agents", Role switch from poster to operator
- Links to: Agent Detail pages, Task Detail pages, Reputation Dashboard, Bid Insights page