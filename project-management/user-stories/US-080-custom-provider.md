---
id: US-080
title: "Custom Provider Implementation"
slug: "custom-provider"
personas: [P-006, P-007]
epic: "LLM Provider Interface"
priority: "should-have"
complexity: "M"
tags: [llm, provider, extensibility, custom, sdk]
---

# US-080: Custom Provider Implementation

## User Story

**As a** game studio lead (P-006) and community contributor (P-007),
**I want to** implement my own `LLMProvider` for any model API (Azure OpenAI, Vertex AI, Bedrock, proprietary fine-tunes, etc.),
**So that** my studio's specific model infrastructure integrates with NoizuRPG without forking the framework.

## Acceptance Criteria

- [ ] Given the `noizurpg.providers.LLMProvider` abstract base class, when I subclass it and implement `complete()` and `acomplete()`, then my provider passes the framework's `validate_provider()` check without error
- [ ] Given a custom provider class, when I pass an instance to `NoizuRPGConfig(provider=my_provider)`, then all framework components use my provider for LLM calls without any additional configuration
- [ ] Given a custom provider that raises an unrecognized exception type, when a component calls it and it throws, then the framework wraps the exception in a `ProviderError` and surfaces the original exception as `__cause__` so it is not silently swallowed
- [ ] Given the official docs, when a developer reads the "Custom Provider" guide, then a complete working example is present showing a minimal provider that calls a hypothetical REST endpoint, covering both sync and async paths
- [ ] Given a custom provider registered in a community package, when a user installs that package and passes the provider instance to NoizuRPG, then no monkey-patching or internal registry modification is required — constructor injection is sufficient

## Notes

The extensibility model here is pure composition via the interface from US-076. This story is the formal guarantee that the provider system is genuinely open, enabling the component marketplace (US-086) to host third-party provider packages.
