---
id: US-026
title: "Post-process: convert image formats"
slug: post-process-convert-format
personas: [P-001, P-003]
epic: "Post-Processing"
priority: must-have
complexity: medium
tags: [post-processing, convert, webp, optimization]
---

# US-026: Post-process: convert image formats

## User Story

**As a** developer optimizing web assets
**I want to** convert generated PNGs to WebP for smaller file sizes
**So that** my web pages load faster

## Acceptance Criteria

- **Given** a post-processing step `action: convert` with `to: webp`, `quality: 85`
  **When** generation completes
  **Then** a `.webp` file is created alongside the original

- **Given** multiple output formats declared (png + webp)
  **When** post-processing runs
  **Then** both formats are produced with their specified quality settings

## Notes
Format conversion uses ImageMagick for most formats, cwebp specifically for WebP.
