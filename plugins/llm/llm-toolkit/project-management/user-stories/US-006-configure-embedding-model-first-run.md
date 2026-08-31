---
id: US-006
title: "Configure embedding model on first run"
slug: configure-embedding-model-first-run
personas: [P-001, P-008]
epic: "Onboarding & Install"
priority: must-have
complexity: medium
tags: [onboarding, config, semantic-search]
---

# US-006: Configure Embedding Model On First Run

## User Story

**As a** power-user setting up semantic search (Marcus) or a multi-provider agent tinkerer tracking cost/performance tradeoffs (Yusuf)
**I want to** accept the default MiniLM embedding model or choose an alternative during the first-run wizard
**So that** the initial index is built with the embedding model I actually want, instead of having to re-embed everything later

## Acceptance Criteria

- **Given** the first-run wizard has reached the embedding model step
  **When** it displays, MiniLM is pre-selected as the default with a short description of its tradeoffs (size/speed vs. accuracy)
  **Then** the user can proceed with one click without needing to understand embedding models

- **Given** the user wants an alternative
  **When** they open the model selector
  **Then** they see a list of supported alternative embedding models with basic metadata (dimension size, approximate resource footprint) before choosing

- **Given** the user selects a non-default embedding model
  **When** they confirm the wizard step
  **Then** the choice is persisted to config and the initial index build uses the selected model for all embeddings, not a mix of models

- **Given** the user picks a model that requires an additional download
  **When** the wizard proceeds
  **Then** it shows download progress before indexing starts, rather than blocking silently

## Notes
Yusuf (P-008) explicitly checks context-budget and cost tradeoffs before committing to a config, so exposing model metadata at this step matters to him; Marcus (P-001) just wants the sane default to work without friction.
