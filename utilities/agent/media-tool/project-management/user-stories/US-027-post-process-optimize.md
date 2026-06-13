---
id: US-027
title: "Post-process: optimize images"
slug: post-process-optimize
personas: [P-003]
epic: "Post-Processing"
priority: should-have
complexity: medium
tags: [post-processing, optimize, optipng, compression]
---

# US-027: Post-process: optimize images

## User Story

**As a** DevOps engineer optimizing build artifacts
**I want to** run lossless optimization on generated images
**So that** asset file sizes are minimized without quality loss

## Acceptance Criteria

- **Given** a post-processing step `action: optimize` with `tool: optipng`, `level: 3`
  **When** generation completes
  **Then** the PNG is optimized in-place with optipng at the specified level

- **Given** `tool: pngquant` with `quality: 80`
  **When** optimization runs
  **Then** lossy quantization is applied reducing file size

## Notes
Supports: optipng (lossless), pngquant (lossy), cwebp (WebP optimization), jpegoptim (JPEG).
