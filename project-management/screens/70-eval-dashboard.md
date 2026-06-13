# Eval Quality Dashboard

| Field | Value |
|-------|-------|
| **ID** | `eval-dashboard` |
| **Type** | Dashboard |
| **Category** | Agent Evaluation |
| **User Stories** | US-098 |

## Description

Time-series quality score charts by agent, role, and task type with regression detection, failure mode summaries, and prompt version correlation (correlate quality changes with prompt changes).

## Key Components

- **Time-series charts** — Quality scores plotted over time
- **Filter by agent/role** — Focus on specific agents or roles
- **Regression detection highlights** — Automatic flagging of quality drops
- **Per-agent summary cards** — Quick overview metrics per agent
- **Failure mode breakdown** — Most common failure types
- **Prompt version correlation** — Overlay prompt changes on quality timeline

## Interactions

- Select time range and granularity
- Filter by agent, role, or task type
- Click regression flags for detail
- Correlate quality changes with prompt version changes
- Drill into failure modes for root cause
- Export quality reports

## Navigation

- Accessible from: Eval nav, Agent Team Dashboard
- Links to: Prompt Timeline, A/B Test Manager, Prompt Refinement Suggestions
