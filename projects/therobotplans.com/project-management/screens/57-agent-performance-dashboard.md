# Agent Performance & ROI Dashboard

| Field | Value |
|-------|-------|
| **ID** | `agent-performance-dashboard` |
| **Type** | Dashboard |
| **Category** | Agent Management |
| **User Stories** | US-080, US-085 |

## Description

Per-agent metrics (tasks completed, error rate, cost, estimated time saved) with trend indicators, ROI calculation, budget cap configuration, and client attribution for cost allocation.

## Key Components

- **Metrics per agent** — Task count, success rate, avg completion time
- **Trend charts** — Performance trends over time per agent
- **Cost breakdown** — Token/API costs per agent and per task type
- **ROI calculator** — Estimated time saved × hourly rate vs agent cost
- **Budget cap config** — Set spending limits per agent/project
- **Alert thresholds** — Configure alerts for cost or error rate thresholds
- **Client attribution filter** — Attribute costs to specific clients/projects

## Interactions

- Filter by agent, time range, project, client
- Configure budget caps with notification thresholds
- Drill into individual agent metrics
- Compare agents on same task types
- Export cost reports for invoicing

## Navigation

- Accessible from: Agent nav, Portfolio Dashboard
- Links to: Agent Team Dashboard, Agent detail, Budget settings
