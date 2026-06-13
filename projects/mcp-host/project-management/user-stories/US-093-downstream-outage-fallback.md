---
id: US-093
title: "System handles downstream service outage gracefully with cached fallback"
slug: "downstream-outage-fallback"
personas: [P-002, P-004]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "L"
tags: [error-states, resilience, fallback, caching, downstream-outage]
---

# US-093: System Handles Downstream Service Outage Gracefully with Cached Fallback

## User Story

**As a** Platform Engineer (P-002),
**I want to** have the platform gracefully handle downstream service outages by serving cached responses or clear degraded-mode errors,
**So that** transient failures in external services do not cascade into complete tool unavailability and users understand the degraded state.

## Acceptance Criteria

- [ ] Given a tool invocation targets a downstream service that is unreachable (connection timeout, DNS failure, 5xx response), when the sandbox detects the failure, then the platform returns a structured error response indicating the downstream service name, the failure type (timeout, connection refused, server error), and a suggested retry interval
- [ ] Given a tool has caching enabled in its manifest and a previous successful response is cached, when a downstream service becomes unavailable, then the platform serves the cached response with an additional metadata header indicating "stale-cache-hit" and the age of the cached response
- [ ] Given a downstream service outage affects multiple tool invocations, when the platform detects a pattern of consecutive failures (3+ failures in 60 seconds), then it marks the downstream service as "degraded" in the service health dashboard and routes subsequent invocations directly to cached fallback or fast-fail without waiting for the full timeout
- [ ] Given a downstream service recovers from an outage, when the platform's health check succeeds, then the degraded status is cleared and new invocations are routed to the live service, invalidating stale cache entries

## Notes

Caching behavior is opt-in per tool -- not all tools should serve stale data (e.g., write operations, real-time queries). The cached fallback TTL and staleness tolerance should be configurable in the tool manifest. Related to US-084 (connected service authorizations) and the sandbox execution model.
