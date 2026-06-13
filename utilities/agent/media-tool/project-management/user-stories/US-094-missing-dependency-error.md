---
id: US-094
title: "Skip prompts with missing dependencies"
slug: missing-dependency-error
personas: [P-001, P-003]
epic: "Error Handling & Resilience"
priority: must-have
complexity: medium
tags: [error-handling, dependencies, graceful-skip]
---

# US-094: Skip prompts with missing dependencies

## User Story

**As a** user running batch generation
**I want to** prompts whose dependencies failed to be skipped gracefully
**So that** independent assets still generate even if one dependency chain breaks

## Acceptance Criteria

- **Given** prompt B depends on prompt A, and prompt A fails
  **When** the pipeline processes prompt B
  **Then** B is skipped with a message indicating the failed dependency

- **Given** prompt C has no dependency on A
  **When** A fails
  **Then** C is generated normally

## Notes
Dependency failure cascades only to dependents. Independent prompts in the same or later tiers proceed normally.
