---
id: US-078
title: "Built-in Anthropic Provider"
slug: "anthropic-provider"
personas: [P-001]
epic: "LLM Provider Interface"
priority: "must-have"
complexity: "S"
tags: [llm, anthropic, claude, provider, integration]
---

# US-078: Built-in Anthropic Provider

## User Story

**As an** indie AI game developer (P-001),
**I want to** use Anthropic's Claude models out of the box with just an API key,
**So that** I can leverage Claude's strong narrative and reasoning capabilities without writing any provider glue code.

## Acceptance Criteria

- [ ] Given `ANTHROPIC_API_KEY` is set in the environment, when I instantiate `AnthropicProvider()` with no arguments, then it reads the key automatically and is ready for use
- [ ] Given an `AnthropicProvider` instance, when I call `complete(prompt, model="claude-opus-4-5")`, then it returns a valid `LLMResponse` with `provider="anthropic"` and the correct `model` field populated
- [ ] Given an `AnthropicProvider` instance, when I call `acomplete(prompt)`, then it executes asynchronously using Anthropic's async client and returns the same `LLMResponse` shape
- [ ] Given an Anthropic API overload or rate-limit response, when the provider receives it, then it raises a typed `ProviderRateLimitError` with the retry-after value accessible if present in the response headers
- [ ] Given `pip install noizurpg[anthropic]`, when the package installs, then the `anthropic` SDK is included and `AnthropicProvider` is importable from `noizurpg.providers`

## Notes

Implements the `LLMProvider` interface defined in US-076. The extras group pattern mirrors US-077 to keep the base install minimal. Claude's extended context windows make this provider particularly relevant for the Memory System and long Narrative Engine sessions.
