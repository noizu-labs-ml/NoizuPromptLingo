# Resource Metrics

| Field | Value |
|-------|-------|
| **ID** | `resource-metrics` |
| **Type** | Dashboard |
| **Category** | Resources |
| **User Stories** | US-030 |

## Description

Owner-only usage metrics dashboard for a resource. Shows view count, fork count, and usage count per version with time-series trends and per-version breakdowns.

## Key Components

- **Version Metrics Table** — View/fork/usage count per version (US-030)
- **Sort Controls** — Most viewed, most forked, most used (US-030)
- **Time Series Graph** — Usage trends over time (US-030)
- **Per-Version Breakdown** — Spaces where version is used (US-030)
- **Metrics Aggregation Indicator** — Daily update note (US-030)
- **Private Resource Gating** — Owner-only access control (US-030)

## Interactions

- Sort by metric; view time series; drill into version details

## Navigation

- Accessible from: Resource Detail (26) for owners
- Links to: Resource Detail (26)
