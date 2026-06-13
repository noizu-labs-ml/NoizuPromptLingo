---
id: US-002
title: "Generate multiple variants of an image"
slug: generate-multiple-variants
personas: [P-001, P-006]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [variants, generation, batch]
---

# US-002: Generate multiple variants of an image

## User Story

**As a** developer generating brand assets
**I want to** run `generate-media-prompt -n 3 hero.media.prompt` to get multiple candidates
**So that** I can pick the best variant for my project

## Acceptance Criteria

- **Given** a valid prompt file
  **When** I run `generate-media-prompt -n 3 hero.media.prompt`
  **Then** three files are generated: `hero.png`, `hero.2.png`, `hero.3.png`

- **Given** vision evaluation is configured (GROQ_API_KEY set) and eval criteria exist
  **When** variants are generated
  **Then** the best variant is identified via automated scoring

## Notes
Variant naming follows the documented convention. Vision eval is optional enhancement.
