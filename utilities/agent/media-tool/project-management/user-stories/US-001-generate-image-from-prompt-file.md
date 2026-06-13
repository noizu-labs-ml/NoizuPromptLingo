---
id: US-001
title: "Generate a single image from a prompt file"
slug: generate-image-from-prompt-file
personas: [P-001, P-008]
epic: "Core Generation"
priority: must-have
complexity: low
tags: [image, generation, basic]
---

# US-001: Generate a single image from a prompt file

## User Story

**As a** solo developer
**I want to** run `generate-media-prompt hero.media.prompt` and get a PNG image
**So that** I can produce visual assets from declarative YAML without opening a browser

## Acceptance Criteria

- **Given** a valid `.media.prompt` file with `type: image` and `service: gemini`
  **When** I run `generate-media-prompt hero.media.prompt`
  **Then** a `hero.png` file appears in the same directory as the prompt file

- **Given** the output file already exists
  **When** I run without `--force`
  **Then** the existing file is preserved and generation is skipped with a message

## Notes
Core happy path. This is the most basic usage pattern.
