---
id: US-050
title: "Tag prompts for filtering and grouping"
slug: tag-and-product-target-metadata
personas: [P-002, P-003]
epic: "Output & Naming"
priority: should-have
complexity: low
tags: [tags, product-targets, metadata, filtering]
---

# US-050: Tag prompts for filtering and grouping

## User Story

**As a** content strategist managing many prompts
**I want to** tag `.media.prompt` files with metadata
**So that** I can filter and batch-generate specific categories of assets

## Acceptance Criteria

- **Given** `tags: [hero, landing, dark-theme]` and `product_targets: [og-card, social-preview]`
  **When** the prompt is parsed
  **Then** tags and product targets are stored as metadata

- **Given** a `--tag hero` CLI filter (planned)
  **When** generation runs on a directory
  **Then** only prompts with the matching tag are processed

## Notes
Tag filtering is a planned feature (`--tag`). Metadata is parsed and stored now for future filtering.
