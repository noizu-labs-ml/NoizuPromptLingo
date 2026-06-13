---
id: US-034
title: "Use style templates for consistent aesthetics"
slug: style-reference-templates
personas: [P-002, P-006]
epic: "Evaluation & Quality"
priority: should-have
complexity: medium
tags: [style, template, consistency, branding]
---

# US-034: Use style templates for consistent aesthetics

## User Story

**As a** content creator producing a series
**I want to** use `prompt.style` templates for consistent visual aesthetics
**So that** all assets in a series look cohesive

## Acceptance Criteria

- **Given** a `prompt.style` field with a template slug (e.g., `kawaii`, `photography`)
  **When** generation runs
  **Then** the style template is prepended to or used to guide the generation

- **Given** an invalid style slug
  **When** the prompt is parsed
  **Then** a warning lists available style templates

## Notes
Style templates are a planned feature. They map to curated system prompts and provider_option presets.
