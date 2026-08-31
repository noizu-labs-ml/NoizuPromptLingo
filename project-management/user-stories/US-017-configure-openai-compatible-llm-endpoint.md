---
id: US-017
title: "Configure OpenAI-compatible LLM endpoint"
slug: configure-openai-compatible-llm-endpoint
personas: [P-008]
epic: "Settings & LLM Provider Config"
priority: must-have
complexity: medium
tags: [settings, llm-config]
---

# US-017: Configure OpenAI-Compatible LLM Endpoint

## User Story

**As a** multi-provider agent tinkerer configuring alternate providers for cost control
**I want to** point simplify/summarize/convert operations at any OpenAI-compatible endpoint by setting base URL, API key, and model name
**So that** I can use a cheaper or self-hosted model instead of the built-in default for these operations

## Acceptance Criteria

- **Given** the user opens Settings' LLM provider section
  **When** they enter a base URL, API key, and model name for an OpenAI-compatible endpoint
  **Then** saving the settings persists them (API key stored securely, not in plaintext config visible in the UI after save) and the fields are validated as non-empty before allowing save

- **Given** a custom provider is configured and saved
  **When** the user triggers a simplify, summarize, or convert operation
  **Then** the request is sent to the configured base URL/model instead of the built-in default provider

- **Given** the user enters an invalid base URL (malformed URL, unreachable host)
  **When** they attempt to save
  **Then** the form shows a validation error indicating the URL is malformed, without requiring a live network call to catch basic format errors

- **Given** a custom provider was previously configured
  **When** the user clears the fields or selects "use built-in default"
  **Then** operations revert to the built-in default provider

## Notes
Core to Yusuf's (P-008) workflow of configuring alternate OpenAI-compatible providers for cost control; pairs with US-020 (test connection) for live validation and US-019 (per-operation override) for finer-grained control beyond this single global setting.
