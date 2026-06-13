---
id: US-079
title: "Built-in Ollama Provider for Local Dev"
slug: "ollama-provider"
personas: [P-001, P-003, P-004]
epic: "LLM Provider Interface"
priority: "must-have"
complexity: "M"
tags: [llm, ollama, local, provider, offline, dev]
---

# US-079: Built-in Ollama Provider for Local Dev

## User Story

**As an** indie AI game developer (P-001), AI/ML researcher (P-003), and tabletop GM (P-004),
**I want to** run NoizuRPG entirely on a local Ollama instance with no cloud API keys,
**So that** I can develop offline, avoid API costs during iteration, and keep sensitive world-building data off external servers.

## Acceptance Criteria

- [ ] Given a running Ollama server at `http://localhost:11434`, when I instantiate `OllamaProvider()` with no arguments, then it connects to the default endpoint and is ready without any API key
- [ ] Given an `OllamaProvider(base_url="http://custom-host:11434")`, when I call `complete(prompt, model="llama3")`, then it routes the request to the specified host and returns a valid `LLMResponse`
- [ ] Given an `OllamaProvider` instance, when I call `complete()` and Ollama is not running, then it raises a `ProviderConnectionError` with a human-readable message indicating the endpoint that was unreachable
- [ ] Given an Ollama provider configured on the framework, when I run the full integration test suite locally, then all tests pass without any cloud API calls being made
- [ ] Given `pip install noizurpg[ollama]`, when the package installs, then only the `httpx` dependency is added (no heavy ML libraries) and `OllamaProvider` is importable from `noizurpg.providers`
- [ ] Given an `OllamaProvider` instance, when I call `list_models()`, then it returns a list of model names currently available on the connected Ollama server

## Notes

Implements the `LLMProvider` interface defined in US-076. This is the zero-cost entry point for P-004 (tabletop GMs) who want to experiment without committing to API spend. Pairs with deterministic mode (US-093) for fully reproducible local CI runs.
