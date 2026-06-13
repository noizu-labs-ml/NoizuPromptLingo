---
id: US-016
title: "Resolve dependency DAG across prompt files"
slug: resolve-dependency-dag
personas: [P-001, P-003]
epic: "Pipeline & Dependencies"
priority: must-have
complexity: high
tags: [dag, dependencies, topological-sort, kahn]
---

# US-016: Resolve dependency DAG across prompt files

## User Story

**As a** developer with multi-step asset pipelines
**I want to** declare dependencies between `.media.prompt` files
**So that** assets are generated in the correct order (logo before hero, hero before animation)

## Acceptance Criteria

- **Given** a directory with `logo.media.prompt` (no deps) and `hero.media.prompt` (depends on `logo-001`)
  **When** I run `generate-media-prompt assets/`
  **Then** the logo is generated first, then the hero uses the logo output

- **Given** a circular dependency (A depends on B, B depends on A)
  **When** the DAG is resolved
  **Then** the tool aborts with an error listing the cycle

## Notes
Uses Kahn's algorithm for topological sort. Dependencies matched by `id` field.
