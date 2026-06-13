---
id: US-091
title: "Chain image generation into video generation"
slug: image-to-video-chain
personas: [P-004]
epic: "Pipeline & Dependencies"
priority: should-have
complexity: medium
tags: [dependencies, image-to-video, chain, pipeline]
---

# US-091: Chain image generation into video generation

## User Story

**As a** content creator producing trailers
**I want to** chain image generation into video generation
**So that** a generated hero image becomes the base frame for a short video clip

## Acceptance Criteria

- **Given** a logo prompt and a video prompt that depends on it via `collapse: file`
  **When** batch generation runs
  **Then** the logo is generated first, then used as the base image for the video

- **Given** the dependency output is a PNG
  **When** the video provider receives it
  **Then** the PNG is attached as the `role: base` image for image-to-video generation

## Notes
This is the core cross-type dependency chain: image → video. Tests the full DAG pipeline.
