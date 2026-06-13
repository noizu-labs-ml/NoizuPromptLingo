---
id: US-004
title: "Configure LLM provider"
slug: "configure-llm-provider"
personas: [P-001, P-003]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "S"
tags: [configuration, llm, provider, api-key, yaml]
---

# US-004: Configure LLM Provider

## User Story

**As an** indie AI game developer or AI/ML researcher (P-001, P-003),
**I want to** configure which LLM provider NoizuRPG uses via a YAML config file or environment variables,
**So that** I can swap between OpenAI, Anthropic, Ollama, or other providers without changing game code.

## Acceptance Criteria

- [ ] Given a `config.yaml` with `llm.provider: openai` and `llm.model: gpt-4o`, when the framework initializes, then all LLM calls are routed to the OpenAI API using the key from the `OPENAI_API_KEY` environment variable.
- [ ] Given a `config.yaml` with `llm.provider: anthropic` and `llm.model: claude-opus-4-5`, when the framework initializes, then all LLM calls are routed to the Anthropic API using the key from the `ANTHROPIC_API_KEY` environment variable.
- [ ] Given a `config.yaml` with `llm.provider: ollama` and `llm.model: llama3`, when the framework initializes, then all LLM calls are routed to the local Ollama server at `http://localhost:11434` with no API key required.
- [ ] Given an environment variable `NOIZURPG_LLM_PROVIDER=anthropic` is set, when the framework initializes, then the environment variable takes precedence over the `config.yaml` provider setting.
- [ ] Given an invalid provider name in `config.yaml`, when the framework initializes, then it raises a `ConfigurationError` with a message listing the supported provider names.
- [ ] Given a missing API key for a cloud provider, when the first LLM call is made, then the framework raises an `AuthenticationError` with a message indicating which environment variable must be set.

## Notes

LLM-agnosticism is a core NoizuRPG value proposition. The provider abstraction must be clean enough that researchers like James (P-003) can plug in custom or fine-tuned models via a `custom` provider type with a callable interface. See US-006 for the Ollama-specific local development story.
