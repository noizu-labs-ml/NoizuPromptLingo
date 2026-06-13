---
id: US-052
title: "Skip malformed requests and continue batch"
slug: skip-bad-requests
personas: [P-003]
epic: "Error Handling & Resilience"
priority: must-have
complexity: low
tags: [error-handling, skip, continue, batch]
---

# US-052: Skip malformed requests and continue batch

## User Story

**As a** user running batch generation on a directory
**I want to** bad prompts to be skipped without stopping the entire batch
**So that** one broken file doesn't prevent generating all other assets

## Acceptance Criteria

- **Given** an API returns HTTP 400 (bad request)
  **When** the error occurs
  **Then** the prompt is skipped, the error body is logged, and the next prompt is processed

- **Given** multiple bad prompts in a batch
  **When** processing completes
  **Then** a summary shows succeeded vs. skipped counts

## Notes
400 errors are recoverable — skip and continue. Contrast with 401/403 which are fatal (bad API key).
