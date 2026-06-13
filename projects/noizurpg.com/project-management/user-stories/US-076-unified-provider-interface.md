---
id: US-076
title: "Unified Provider Interface for LLM Calls"
slug: "unified-provider-interface"
personas: [P-001, P-006]
epic: "LLM Provider Interface"
priority: "must-have"
complexity: "M"
tags: [llm, provider, abstraction, architecture]
---

# US-076: Unified Provider Interface for LLM Calls

## User Story

**As an** indie AI game developer (P-001) and game studio lead (P-006),
**I want to** call any LLM through a single, consistent Python interface,
**So that** my game logic is decoupled from any specific AI provider and I can swap or upgrade models without rewriting application code.

## Acceptance Criteria

- [ ] Given a NoizuRPG project, when I instantiate any built-in or custom provider, then it implements a `LLMProvider` abstract base class with `complete(prompt, **kwargs) -> LLMResponse` and `acomplete(prompt, **kwargs) -> LLMResponse` (async) methods
- [ ] Given an `LLMResponse` object, when I access its fields, then it exposes `text: str`, `tokens_used: int`, `model: str`, `provider: str`, and `raw: dict` attributes regardless of which provider generated it
- [ ] Given a component (e.g., NarrativeEngine) configured with a provider, when the component makes an LLM call internally, then it routes through the injected `LLMProvider` instance rather than a hard-coded SDK
- [ ] Given a provider configured at the framework level, when no provider is specified on an individual component, then the component inherits the global default provider
- [ ] Given invalid provider configuration (missing API key, bad endpoint), when the framework initializes, then it raises a descriptive `ProviderConfigError` with actionable guidance before any game logic runs

## Notes

This is the foundational contract all other LLM-related stories depend on. Built-in providers (US-077, US-078, US-079) and custom providers (US-080) all implement this interface. Provider fallback chains (US-081) compose multiple `LLMProvider` instances using this same contract.
