---
id: US-046
title: "Handle LLM failures gracefully"
slug: "llm-failure-handling"
personas: [P-006]
epic: "Narrative Engine"
priority: "must-have"
complexity: "M"
tags: [narrative-engine, resilience, error-handling, llm, production]
---

# US-046: Handle LLM Failures Gracefully

## User Story

**As a** game studio lead operating a production game with SLA requirements (P-006),
**I want to** configure the Narrative Engine with retry policies, circuit breakers, and fallback responses for LLM failures,
**So that** transient API outages or rate-limit errors degrade gracefully without crashing the game session or surfacing raw exceptions to players.

## Acceptance Criteria

- [ ] Given an LLM API call that returns a rate-limit error (HTTP 429), when the engine's retry policy is `{"max_retries": 3, "backoff": "exponential", "base_delay": 1.0}`, then the call is retried up to 3 times with delays of 1s, 2s, 4s before raising `LLMRateLimitExhausted`.
- [ ] Given an LLM API call that raises a network timeout, when `max_retries` is configured, then it is retried; when all retries fail, then `LLMUnavailableError` is raised with the last exception chained.
- [ ] Given a fallback narrative configured via `engine.set_fallback("The world holds its breath...")`, when all retries fail, then `engine.generate()` returns the fallback string wrapped in a `NarrativeResult` with `fallback_used=True` rather than raising.
- [ ] Given a circuit breaker configured with `failure_threshold=5, recovery_timeout=60`, when 5 consecutive LLM failures occur within a session, then the circuit opens and subsequent `engine.generate()` calls immediately return the fallback without attempting the LLM, until 60 seconds have elapsed.
- [ ] Given a circuit in open state, when recovery timeout elapses and the next call succeeds, then the circuit closes and normal operation resumes.
- [ ] Given any LLM failure scenario, when the failure occurs, then the event is logged at `ERROR` level with the error type, attempt number, and elapsed time, without leaking API keys or request bodies to logs.

## Notes

Production resilience is P-006's top operational concern. Retry and circuit breaker configuration should be available via `engine.configure_resilience(**kwargs)` or the world YAML config. This story does not cover model fallback (switching LLM providers) — that is a separate concern for the adapter layer.
