---
id: US-086
title: "Handle concurrent API calls across providers"
slug: concurrent-multi-provider
personas: [P-003]
epic: "Performance & Scale"
priority: should-have
complexity: high
tags: [performance, async, tokio, concurrent, provider]
---

# US-086: Handle concurrent API calls across providers

## User Story

**As a** DevOps engineer optimizing generation speed
**I want to** different providers to be called concurrently
**So that** a batch mixing Gemini and Suno calls completes faster

## Acceptance Criteria

- **Given** independent prompts using different providers (Gemini, Anthropic, Suno)
  **When** they're in the same tier
  **Then** all API calls are made concurrently

- **Given** rate limits per provider
  **When** concurrent calls exceed the limit
  **Then** backoff is applied per-provider, not globally

## Notes
tokio async tasks enable per-provider concurrency. Rate limits are provider-specific.
