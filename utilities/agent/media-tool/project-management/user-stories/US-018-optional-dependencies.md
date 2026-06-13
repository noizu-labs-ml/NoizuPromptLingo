---
id: US-018
title: "Mark dependencies as optional"
slug: optional-dependencies
personas: [P-003]
epic: "Pipeline & Dependencies"
priority: should-have
complexity: medium
tags: [dependencies, optional, graceful-degradation]
---

# US-018: Mark dependencies as optional

## User Story

**As a** DevOps engineer running CI pipelines
**I want to** mark some dependencies as `optional: true`
**So that** generation continues even if a non-critical dependency fails

## Acceptance Criteria

- **Given** a dependency declared with `optional: true`
  **When** the dependency generation fails
  **Then** a warning is logged and the dependent prompt continues without the alias value

- **Given** a dependency declared with `optional: false` (default)
  **When** the dependency generation fails
  **Then** the dependent prompt is skipped with an error

## Notes
Optional deps enable graceful degradation in CI pipelines where some assets are nice-to-have.
