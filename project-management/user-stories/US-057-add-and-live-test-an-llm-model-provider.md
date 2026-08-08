---
id: US-057
title: "Add and Live-Test an LLM Model Provider"
slug: "add-and-live-test-an-llm-model-provider"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "must-have"
complexity: "M"
tags: [admin, llm-catalog, connectivity-test]
---

# US-057: Add and Live-Test an LLM Model Provider

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** add a new LLM model to the platform's model catalog and live-test its connectivity against the real provider,
**So that** I can confirm credentials and network access work before any org is allowed to use that model.

## Acceptance Criteria

- [ ] Given Ilya is on the admin model catalog page, when he adds a new model entry (provider, model ID, API key) for a supported provider — OpenAI, Anthropic, Groq, Cerebras, DeepSeek, or Ollama — and saves, then the model appears in the catalog with an "untested" connectivity status.
- [ ] Given a newly added model entry, when Ilya triggers "test connectivity," then the system makes a live call to the real provider and updates status to "connected" on success or "failed" with the provider's error detail on failure.
- [ ] Given a model's API key is saved, when Ilya or any other admin views the catalog, then the key is displayed masked (e.g., last 4 characters only), never in plaintext.
- [ ] Given a model fails its live connectivity test, when Ilya attempts to publish/enable it for org use, then the system warns that the model has not passed connectivity testing.

## Notes

"Live" means a real outbound call to the provider, not a mock or format-only check. Provider set matches the fixed platform roster.
