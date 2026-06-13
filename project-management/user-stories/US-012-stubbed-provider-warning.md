---
id: US-012
title: "See clear warning for stubbed providers"
slug: stubbed-provider-warning
personas: [P-001, P-005]
epic: "Provider Management"
priority: must-have
complexity: low
tags: [provider, stub, error-message, ux]
---

# US-012: See clear warning for stubbed providers

## User Story

**As a** user trying a planned provider
**I want to** see a clear warning that the provider is not yet implemented
**So that** I understand why generation fails and what my alternatives are

## Acceptance Criteria

- **Given** a `.media.prompt` with a stubbed service (e.g., `openai`, `stability`)
  **When** I run generation
  **Then** a warning message indicates the provider is not yet implemented, lists which providers ARE available, and exits gracefully

- **Given** `--dry-run` mode
  **When** the service is stubbed
  **Then** the stub warning appears in the plan output without erroring

## Notes
Stubbed providers should parse config correctly but decline to make API calls.
