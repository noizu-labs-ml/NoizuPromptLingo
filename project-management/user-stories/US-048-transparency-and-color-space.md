---
id: US-048
title: "Request transparency and color space settings"
slug: transparency-and-color-space
personas: [P-001, P-004]
epic: "Output & Naming"
priority: should-have
complexity: low
tags: [output, transparency, color-space, print]
---

# US-048: Request transparency and color space settings

## User Story

**As a** developer generating logos and sprites
**I want to** request transparent backgrounds and specific color spaces
**So that** assets work correctly in compositing and print contexts

## Acceptance Criteria

- **Given** `output.transparency: required`
  **When** the API call is made
  **Then** the provider is instructed to produce a transparent background

- **Given** `output.color_space: CMYK`
  **When** output is produced
  **Then** the image uses CMYK color space (for print use)

- **Given** `output.dpi: 300`
  **When** output is produced
  **Then** the DPI metadata is set for print-quality output

## Notes
Transparency, color space, and DPI are hints — providers may not support all combinations.
