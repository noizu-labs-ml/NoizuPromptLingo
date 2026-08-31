---
id: US-086
title: "LLM provider request failure surfaced clearly"
slug: llm-provider-request-failure-surfaced
personas: [P-008]
epic: "Edge Cases & Error States"
priority: should-have
complexity: medium
tags: [error-state, llm-config]
---

# US-086: LLM Provider Request Failure Surfaced Clearly

## User Story

**As a** multi-provider agent tinkerer
**I want to** see a specific, retry-able error when a configured LLM provider call fails during simplify/convert
**So that** I know which provider/config is at fault instead of guessing from a generic failure message

## Acceptance Criteria

- **Given** Yusuf has configured an OpenAI-compatible provider in Settings and the endpoint times out during a simplify operation
  **When** the timeout occurs
  **Then** the UI shows "Request to <provider> timed out" with a Retry button

- **Given** the configured provider returns a 401 auth error during Convert's AI-suggested candidate scoring
  **When** that happens
  **Then** the error states "authentication failed" and links back to Settings to fix the API key

- **Given** a retry-able error is shown
  **When** Yusuf clicks Retry
  **Then** the same operation re-runs with the same input without requiring him to reconfigure anything

## Notes
Yusuf configures alternate OpenAI-compatible providers for cost control and juggles several endpoints; a generic "something went wrong" would hide which provider/config is actually at fault.
