---
id: US-051
title: "Retry on API rate limiting"
slug: rate-limit-retry
personas: [P-003]
epic: "Error Handling & Resilience"
priority: must-have
complexity: medium
tags: [error-handling, retry, rate-limit, backoff]
---

# US-051: Retry on API rate limiting

## User Story

**As a** DevOps engineer running batch generation
**I want to** the tool to retry automatically when rate-limited
**So that** batch jobs complete without manual intervention

## Acceptance Criteria

- **Given** an API returns HTTP 429
  **When** the request fails
  **Then** exponential backoff retries occur (2s → 4s → 8s), up to 3 attempts

- **Given** all retries are exhausted
  **When** the final attempt fails
  **Then** the prompt is skipped and an error is logged, processing continues

## Notes
Backoff: 2s, 4s, 8s. Other prompts in the batch are not affected by one rate-limited prompt.
