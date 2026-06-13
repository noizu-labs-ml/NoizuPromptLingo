---
id: US-020
title: "Generate independent assets in parallel within a tier"
slug: parallel-within-tier-generation
personas: [P-003]
epic: "Pipeline & Dependencies"
priority: should-have
complexity: high
tags: [parallel, async, tier, performance]
---

# US-020: Generate independent assets in parallel within a tier

## User Story

**As a** DevOps engineer optimizing build times
**I want to** generate assets that have no mutual dependencies concurrently
**So that** batch generation completes faster

## Acceptance Criteria

- **Given** 5 prompt files at tier 0 (no dependencies)
  **When** generation runs
  **Then** all 5 API calls are made concurrently via tokio async tasks

- **Given** tier 0 has 3 assets and tier 1 has 2 assets depending on tier 0
  **When** generation runs
  **Then** tier 0 completes first (in parallel), then tier 1 runs (in parallel)

## Notes
Requires tokio async runtime. Currently sequential; parallel execution is planned. Per-provider rate limits may constrain concurrency.
