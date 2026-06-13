---
id: US-053
title: "Die immediately on authentication errors"
slug: fatal-auth-errors
personas: [P-001, P-003]
epic: "Error Handling & Resilience"
priority: must-have
complexity: low
tags: [error-handling, auth, fatal, api-key]
---

# US-053: Die immediately on authentication errors

## User Story

**As a** user with a misconfigured API key
**I want to** the tool to stop immediately with a clear error
**So that** I don't waste time running failed requests

## Acceptance Criteria

- **Given** an API returns HTTP 401 or 403
  **When** the error occurs
  **Then** the tool dies immediately with a message indicating the provider, the key name, and where to get it

- **Given** the error occurs mid-batch
  **When** it's an auth error
  **Then** no further prompts for that provider are attempted

## Notes
Auth errors are non-recoverable — retrying won't help. Immediate death saves API quota and time.
