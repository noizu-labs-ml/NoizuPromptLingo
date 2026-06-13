---
id: US-093
title: "Control temperature and token limits"
slug: temperature-and-token-controls
personas: [P-001, P-002]
epic: "Provider Management"
priority: must-have
complexity: low
tags: [provider-options, temperature, tokens, quality]
---

# US-093: Control temperature and token limits

## User Story

**As a** developer tuning generation quality
**I want to** set temperature and max_tokens for chat completion providers
**So that** I can balance between creativity and determinism

## Acceptance Criteria

- **Given** `provider_options: { temperature: 0.2 }`
  **When** the API is called
  **Then** low temperature produces more deterministic, focused output

- **Given** `provider_options: { max_tokens: 8192 }`
  **When** the API is called
  **Then** the output can be up to 8192 tokens long

## Notes
Temperature 0.0-0.3 for diagrams/code. 0.3-0.7 for creative writing. Max tokens limits output length.
