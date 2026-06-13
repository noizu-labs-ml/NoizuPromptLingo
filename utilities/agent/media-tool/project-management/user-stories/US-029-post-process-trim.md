---
id: US-029
title: "Post-process: trim whitespace"
slug: post-process-trim
personas: [P-001]
epic: "Post-Processing"
priority: could-have
complexity: low
tags: [post-processing, trim, whitespace]
---

# US-029: Post-process: trim whitespace

## User Story

**As a** developer generating SVG-based illustrations
**I want to** trim excess whitespace from generated images
**So that** assets have tight bounding boxes

## Acceptance Criteria

- **Given** a post-processing step `action: trim` with `fuzz: 10`
  **When** generation completes
  **Then** whitespace within the fuzz tolerance is trimmed from all edges

## Notes
Uses ImageMagick `-trim` with optional `-fuzz` for near-white/near-transparent edge pixels.
