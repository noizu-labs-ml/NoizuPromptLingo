---
id: US-082
title: "Response Caching for Deterministic Testing"
slug: "response-caching"
personas: [P-003, P-001]
epic: "LLM Provider Interface"
priority: "should-have"
complexity: "M"
tags: [llm, caching, testing, determinism, dev-experience]
---

# US-082: Response Caching for Deterministic Testing

## User Story

**As an** AI/ML researcher (P-003) and indie game developer (P-001),
**I want to** cache LLM responses keyed by prompt content so that repeated test runs return identical responses without making live API calls,
**So that** my test suite is fast, free, and reproducible across machines and CI environments.

## Acceptance Criteria

- [ ] Given a `CachingProvider(backend=provider, cache=DiskCache("./fixtures/llm"))`, when I call `complete(prompt)` for the first time, then the response is fetched live and written to the cache directory as a JSON file named by the SHA-256 hash of the normalized prompt
- [ ] Given a cached prompt, when I call `complete(prompt)` a second time with the identical prompt text, then the cached response is returned without any network call and `LLMResponse.cached == True`
- [ ] Given `CachingProvider(mode="record")`, when tests run, then all cache misses are populated (record mode); given `mode="replay"`, when a cache miss occurs, then a `CacheMissError` is raised immediately rather than making a live call
- [ ] Given a `CachingProvider`, when I call `complete(prompt, model="gpt-4o")` and then `complete(prompt, model="gpt-3.5-turbo")`, then the two responses are stored under separate cache keys (model is part of the cache key)
- [ ] Given a project using `CachingProvider` in CI, when the cache directory is committed to version control, then tests run offline with zero API cost and produce byte-for-byte identical `LLMResponse` objects on any machine

## Notes

`CachingProvider` wraps any `LLMProvider` (US-076), making it composable with `FallbackProvider` (US-081). This pairs directly with deterministic mode (US-093) to give researchers and CI pipelines fully reproducible pipelines. Cache invalidation is manual — developers clear the cache directory when they want fresh responses.
