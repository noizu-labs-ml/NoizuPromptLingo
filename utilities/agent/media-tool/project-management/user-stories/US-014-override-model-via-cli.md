---
id: US-014
title: "Override the model via CLI flag"
slug: override-model-via-cli
personas: [P-001, P-002]
epic: "Provider Management"
priority: should-have
complexity: low
tags: [cli, model, override]
---

# US-014: Override the model via CLI flag

## User Story

**As a** user experimenting with different models
**I want to** override the model specified in the `.media.prompt` file via `--model`
**So that** I can test different models without editing YAML

## Acceptance Criteria

- **Given** a `.media.prompt` with `model: imagen-3.0-generate-002`
  **When** I run `generate-media-prompt --model imagen-4.0-generate-001 hero.media.prompt`
  **Then** generation uses `imagen-4.0-generate-001` instead

- **Given** no `--model` flag
  **When** the `.media.prompt` specifies a model
  **Then** the file's model is used

- **Given** no `--model` flag and no model in the file
  **When** generation runs
  **Then** the provider's default model is used

## Notes
CLI flag takes highest precedence, then file value, then provider default.
