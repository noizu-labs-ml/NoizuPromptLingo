---
id: US-081
title: "Load .envrc.k8.dc for API keys automatically"
slug: envrc-auto-load
personas: [P-003]
epic: "Integration"
priority: must-have
complexity: low
tags: [integration, envrc, api-keys, secrets]
---

# US-081: Load .envrc.k8.dc for API keys automatically

## User Story

**As a** DevOps engineer
**I want to** the tool to load API keys from `.envrc.k8.dc` automatically
**So that** I don't need to source the file manually or set environment variables

## Acceptance Criteria

- **Given** `$INFRA_ROOT/.envrc.k8.dc` exists
  **When** the tool starts
  **Then** API keys are loaded from the file without overriding existing env vars

- **Given** `$HOME/.envrc.k8.dc` exists as fallback
  **When** `$INFRA_ROOT` is not set
  **Then** keys are loaded from the home directory file

## Notes
Does not override existing environment variables. Respects INFRA_ROOT first, then HOME as fallback.
