---
id: US-081
title: "Provider Fallback Chains"
slug: "provider-fallback"
personas: [P-006]
epic: "LLM Provider Interface"
priority: "should-have"
complexity: "M"
tags: [llm, provider, resilience, fallback, reliability]
---

# US-081: Provider Fallback Chains

## User Story

**As a** game studio lead (P-006),
**I want to** configure an ordered list of provider fallbacks so that if my primary LLM provider is unavailable or rate-limited, the framework automatically retries with the next provider,
**So that** my live game service degrades gracefully instead of going down when a single AI provider has an outage.

## Acceptance Criteria

- [ ] Given a `FallbackProvider([primary, secondary, tertiary])`, when the primary provider raises `ProviderServiceError` or `ProviderRateLimitError`, then the framework automatically retries the same prompt against the secondary provider without the calling component being aware of the switch
- [ ] Given a `FallbackProvider` where all providers in the chain fail, when the last provider raises an error, then a `AllProvidersFailedError` is raised containing the list of providers attempted and their respective exceptions
- [ ] Given a `FallbackProvider` with `on_fallback` callback configured, when a fallback occurs, then the callback is invoked with `(failed_provider, error, next_provider)` arguments, enabling metrics or alerting
- [ ] Given a provider that raises a non-transient error (e.g., `ProviderAuthError`), when the fallback chain evaluates it, then it does NOT fall through to the next provider (authentication errors indicate misconfiguration, not transience) and raises immediately
- [ ] Given a `FallbackProvider` instance, when I pass it to `NoizuRPGConfig(provider=fallback_chain)`, then it satisfies the `LLMProvider` interface from US-076 and requires no special handling anywhere in the framework

## Notes

`FallbackProvider` itself implements `LLMProvider` (US-076), making it composable — a fallback chain can contain another fallback chain. This story enables the Managed Models service (US-085) to use a studio's key as primary with the managed model as secondary.
