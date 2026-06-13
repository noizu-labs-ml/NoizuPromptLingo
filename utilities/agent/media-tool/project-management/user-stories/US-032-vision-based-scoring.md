---
id: US-032
title: "Auto-select best variant via vision evaluation"
slug: vision-based-scoring
personas: [P-006]
epic: "Evaluation & Quality"
priority: should-have
complexity: high
tags: [eval, vision, variant-selection, groq]
---

# US-032: Auto-select best variant via vision evaluation

## User Story

**As a** design team lead
**I want to** the tool to automatically pick the best variant when generating multiples
**So that** I don't have to manually review every candidate

## Acceptance Criteria

- **Given** `GROQ_API_KEY` is set and eval criteria exist
  **When** multiple variants are generated (`-n 3`)
  **Then** each variant is scored via vision API and the best is selected

- **Given** no vision API is available
  **When** multiple variants are generated
  **Then** the first variant is used as default with a note that vision eval was skipped

## Notes
Vision eval requires GROQ_API_KEY for cost-effective image analysis. Falls back to first variant gracefully.
