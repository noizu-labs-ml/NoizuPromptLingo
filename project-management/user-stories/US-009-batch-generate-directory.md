---
id: US-009
title: "Batch generate all prompts in a directory"
slug: batch-generate-directory
personas: [P-001, P-003]
epic: "Core Generation"
priority: must-have
complexity: low
tags: [batch, directory, scan]
---

# US-009: Batch generate all prompts in a directory

## User Story

**As a** developer managing multiple assets
**I want to** run `generate-media-prompt assets/` to process all `.media.prompt` files
**So that** I can regenerate all assets in one command

## Acceptance Criteria

- **Given** a directory containing multiple `.media.prompt` files
  **When** I run `generate-media-prompt assets/`
  **Then** all prompt files are discovered recursively and processed in alphabetical order

- **Given** a directory with nested subdirectories
  **When** scanning
  **Then** hidden directories (starting with `.`) are skipped

- **Given** a directory with no `.prompt` files
  **When** scanning
  **Then** a warning message is shown and the tool exits gracefully

## Notes
Recursive scanning skips hidden directories. File order is alphabetical for determinism.
