---
id: US-097
title: "Deterministic generation with seeds"
slug: deterministic-seed-generation
personas: [P-003]
epic: "Evaluation & Quality"
priority: should-have
complexity: medium
tags: [seed, deterministic, reproducibility, testing]
---

# US-097: Deterministic generation with seeds

## User Story

**As a** DevOps engineer ensuring build reproducibility
**I want to** use seed values for deterministic generation
**So that** the same prompt + seed always produces the same output

## Acceptance Criteria

- **Given** a `seed` value in `provider_options`
  **When** a supporting provider is called
  **Then** the seed is passed to the API for deterministic output

- **Given** no seed is specified
  **When** generation runs
  **Then** each generation produces different results

## Notes
Seed support varies by provider. Veo supports `seed`. Other providers may not support deterministic generation.
