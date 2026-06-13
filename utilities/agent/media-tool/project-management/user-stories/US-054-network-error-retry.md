---
id: US-054
title: "Retry on transient network errors"
slug: network-error-retry
personas: [P-003]
epic: "Error Handling & Resilience"
priority: should-have
complexity: medium
tags: [error-handling, network, retry, resilience]
---

# US-054: Retry on transient network errors

## User Story

**As a** user in a flaky network environment
**I want to** transient network errors to be retried automatically
**So that** momentary connectivity issues don't kill a batch run

## Acceptance Criteria

- **Given** a network timeout or connection reset
  **When** the error occurs
  **Then** up to 3 retries with backoff are attempted before failing

- **Given** a DNS resolution failure
  **When** the error occurs
  **Then** the prompt is skipped with an error (not retried — DNS failure is not transient)

## Notes
Distinguish between transient (timeout, reset) and permanent (DNS, host unreachable) network errors.
