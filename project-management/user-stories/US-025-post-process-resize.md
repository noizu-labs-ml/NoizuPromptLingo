---
id: US-025
title: "Post-process: resize generated images"
slug: post-process-resize
personas: [P-001, P-008]
epic: "Post-Processing"
priority: must-have
complexity: medium
tags: [post-processing, resize, image-magick]
---

# US-025: Post-process: resize generated images

## User Story

**As a** developer generating social media assets
**I want to** resize generated images to specific platform dimensions
**So that** I get correctly sized assets without manual editing

## Acceptance Criteria

- **Given** a post-processing step `action: resize` with `width: 1200`, `height: 630`, `fit: cover`
  **When** generation completes
  **Then** the output is resized to 1200x630 using cover fit (crop to fill)

- **Given** `fit: contain`
  **When** resizing
  **Then** the image is resized to fit within dimensions without cropping, adding letterboxing

## Notes
Requires ImageMagick. Fit modes: cover (crop to fill), contain (fit within), exact (stretch).
