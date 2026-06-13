---
id: US-013
title: "Resolve API keys from environment or secrets file"
slug: api-key-resolution
personas: [P-003]
epic: "Provider Management"
priority: must-have
complexity: low
tags: [api-key, config, secrets, envrc]
---

# US-013: Resolve API keys from environment or secrets file

## User Story

**As a** DevOps engineer
**I want to** configure API keys via environment variables or `.envrc.k8.dc`
**So that** secrets are not hardcoded and can be managed centrally

## Acceptance Criteria

- **Given** an API key is set as an environment variable
  **When** generation runs
  **Then** the environment variable is used directly

- **Given** no environment variable is set but `.envrc.k8.dc` exists
  **When** the tool starts
  **Then** it reads and exports keys from the secrets file

- **Given** neither source provides the required key
  **When** generation is attempted
  **Then** the tool exits with an error naming the missing key and where to get it

## Notes
Resolution order: env var → `.envrc.k8.dc` → die with instructions.
