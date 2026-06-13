---
id: US-047
title: "Specify output dimensions and aspect ratio"
slug: output-dimensions-and-aspect-ratio
personas: [P-001, P-004]
epic: "Output & Naming"
priority: must-have
complexity: low
tags: [output, dimensions, aspect-ratio, resolution]
---

# US-047: Specify output dimensions and aspect ratio

## User Story

**As a** developer generating images for specific contexts
**I want to** declare exact dimensions and aspect ratios
**So that** output matches the target use case (hero banner, social card, video frame)

## Acceptance Criteria

- **Given** `output.dimensions: { width: 1440, height: 900, aspect_ratio: "16:10" }`
  **When** the API is called
  **Then** dimensions and aspect ratio are passed to the provider

- **Given** conflicting width/height and aspect_ratio
  **When** the prompt is parsed
  **Then** a warning notes the conflict and the provider uses its own resolution logic

## Notes
Some providers use dimensions, others use aspect_ratio. The engine maps appropriately per provider.
