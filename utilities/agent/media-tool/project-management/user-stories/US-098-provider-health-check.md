---
id: US-098
title: "Validate provider health before batch"
slug: provider-health-check
personas: [P-003]
epic: "Error Handling & Resilience"
priority: could-have
complexity: medium
tags: [error-handling, health-check, provider, validation]
---

# US-098: Validate provider health before batch

## User Story

**As a** DevOps engineer starting a large batch
**I want to** verify that providers are reachable and keys are valid
**So that** I don't waste time on a batch that will fail on the first API call

## Acceptance Criteria

- **Given** multiple providers in a batch run
  **When** the tool starts
  **Then** a lightweight health check (e.g., model list endpoint) verifies each provider

- **Given** a provider is unreachable
  **When** the health check fails
  **Then** a warning is shown listing which prompts will fail due to the unreachable provider

## Notes
Planned feature. Health check should be fast and not count against API quotas. Some providers don't have health endpoints.
