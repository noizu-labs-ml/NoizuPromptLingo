---
id: US-026
title: "Configure LLM API endpoint target"
slug: "configure-llm-api-endpoint-target"
personas: [P-001, P-002]
epic: "Defender — Scan Configuration"
priority: "must-have"
complexity: "M"
tags: [defender, scan-config, endpoint, setup]
---

# US-026: Configure LLM API endpoint target

## User Story

**As a** AI Red Team Lead (P-001),
**I want to** specify the LLM API endpoint URL and request format for a Defender scan,
**So that** the scanner knows where to send attack probes and how to structure requests to the target model.

## Acceptance Criteria

- [ ] Given I am creating a new scan, when I enter an endpoint URL, then the system validates it is a reachable HTTPS URL before proceeding.
- [ ] Given I have entered an endpoint URL, when I specify the request schema (OpenAI-compatible, Anthropic, custom JSON), then the scanner uses that format for all probe payloads.
- [ ] Given I enter an invalid or unreachable URL, when I attempt to proceed, then the system displays a clear error with the specific connectivity failure reason.
- [ ] Given I select a known provider format (OpenAI, Anthropic, Cohere), when I confirm, then the request schema fields are pre-populated with provider defaults.
- [ ] Given a scan is configured, when I view the scan details, then the target endpoint is displayed and masked after the domain.

## Notes

Supports both hosted provider endpoints and self-hosted model servers (e.g., vLLM, Ollama, LiteLLM proxy). Custom JSON schema support is required for non-standard deployments. Depends on auth configuration in US-027.
