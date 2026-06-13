---
id: US-031
title: "Define eval criteria in prompt file"
slug: define-eval-criteria
personas: [P-006]
epic: "Evaluation & Quality"
priority: should-have
complexity: medium
tags: [eval, quality, criteria, scoring]
---

# US-031: Define eval criteria in prompt file

## User Story

**As a** design team lead
**I want to** define weighted quality criteria in `.media.prompt` files
**So that** generated assets are automatically scored against our quality bar

## Acceptance Criteria

- **Given** an `eval` section with criteria, weights, and a pass threshold
  **When** generation completes
  **Then** each criterion is scored on its declared scale

- **Given** `required_pass` criteria listed
  **When** a required criterion fails
  **Then** the asset is marked as rejected regardless of overall score

- **Given** `reject_if` conditions listed
  **When** a condition is detected (e.g., "obvious AI artifacts")
  **Then** the asset is automatically rejected

## Notes
Eval criteria use weighted scoring. Pass threshold is configurable per prompt.
