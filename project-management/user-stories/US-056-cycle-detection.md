---
id: US-056
title: "Detect dependency cycles"
slug: cycle-detection
personas: [P-003, P-005]
epic: "Error Handling & Resilience"
priority: must-have
complexity: medium
tags: [validation, dag, cycle-detection]
---

# US-056: Detect dependency cycles

## User Story

**As a** developer managing complex asset pipelines
**I want to** be alerted to circular dependencies
**So that** I can fix my dependency graph before running generation

## Acceptance Criteria

- **Given** a cycle (A → B → C → A)
  **When** the DAG is resolved
  **Then** an error lists the full cycle: "A → B → C → A"

- **Given** no cycles
  **When** the DAG is resolved
  **Then** a valid topological order is produced

## Notes
Kahn's algorithm detects cycles naturally (not all nodes get visited). Report the specific cycle for debugging.
