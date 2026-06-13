---
id: US-077
title: "Built-in OpenAI Provider"
slug: "openai-provider"
personas: [P-001]
epic: "LLM Provider Interface"
priority: "must-have"
complexity: "S"
tags: [llm, openai, provider, integration]
---

# US-077: Built-in OpenAI Provider

## User Story

**As an** indie AI game developer (P-001),
**I want to** use OpenAI's models (GPT-4o, GPT-4-turbo, etc.) out of the box with just an API key,
**So that** I can start building immediately without writing any provider glue code.

## Acceptance Criteria

- [ ] Given `OPENAI_API_KEY` is set in the environment, when I instantiate `OpenAIProvider()` with no arguments, then it reads the key automatically and is ready for use
- [ ] Given an `OpenAIProvider` instance, when I call `complete(prompt, model="gpt-4o")`, then it returns a valid `LLMResponse` with `provider="openai"` and the correct `model` field populated
- [ ] Given an `OpenAIProvider` instance, when I call `acomplete(prompt)`, then it executes the request asynchronously and returns the same `LLMResponse` shape as the synchronous method
- [ ] Given an OpenAI API rate-limit or transient 5xx error, when the provider receives it, then it raises a `ProviderRateLimitError` or `ProviderServiceError` (respectively) with the underlying status code accessible on the exception
- [ ] Given `pip install noizurpg[openai]`, when the package installs, then `openai` SDK is included as a dependency and `OpenAIProvider` is importable from `noizurpg.providers`

## Notes

Implements the `LLMProvider` interface defined in US-076. The `[openai]` extras group keeps the base package lightweight for users who do not use OpenAI. See US-082 for response caching that wraps this provider during testing.
