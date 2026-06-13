---
id: US-006
title: "Use local Ollama for free development"
slug: "local-ollama-dev"
personas: [P-001, P-004]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "M"
tags: [ollama, local-llm, development, cost, offline]
---

# US-006: Use Local Ollama for Free Development

## User Story

**As an** indie AI game developer or tabletop GM (P-001, P-004),
**I want to** run NoizuRPG against a local Ollama instance during development,
**So that** I can iterate and prototype without incurring API costs or requiring internet access.

## Acceptance Criteria

- [ ] Given Ollama is installed and running locally with `ollama pull llama3` completed, when I set `llm.provider: ollama` and `llm.model: llama3` in `config.yaml`, then NoizuRPG connects to Ollama at `http://localhost:11434` without any API key configuration.
- [ ] Given a custom Ollama port or host, when I set `llm.ollama_base_url: "http://192.168.1.10:11434"` in `config.yaml`, then NoizuRPG uses that URL instead of the default.
- [ ] Given Ollama is not running, when I attempt to process a narrative turn, then NoizuRPG raises a `ProviderConnectionError` with the message "Cannot connect to Ollama at http://localhost:11434. Is Ollama running?"
- [ ] Given a model name that is not pulled in Ollama, when I attempt to process a narrative turn, then NoizuRPG raises a `ModelNotFoundError` with the model name and a suggestion to run `ollama pull {model}`.
- [ ] Given a local Ollama session, when I run 10 consecutive turns, then all responses are generated without timeout errors on hardware with at least 8GB RAM running a 7B parameter model.
- [ ] Given the noizurpg.com documentation, when I navigate to the "Local Development" guide, then I find step-by-step instructions for installing Ollama and configuring NoizuRPG to use it.

## Notes

This story is critical for lowering the barrier to entry for indie developers like Marcus (P-001) who want cost-free prototyping, and for GMs like Sarah (P-004) who may have unreliable internet at the game table. The Ollama integration must be a first-class provider, not an afterthought. See US-004 for the general provider configuration story.
