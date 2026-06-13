---
id: US-100
title: "Use generated image as video base via attachment"
slug: image-to-video-attachment
personas: [P-004]
epic: "Attachments"
priority: should-have
complexity: medium
tags: [attachments, base, image-to-video, dependency]
---

# US-100: Use generated image as video base via attachment

## User Story

**As a** content creator producing animated content
**I want to** use a previously generated image as the base for video generation
**So that** I can animate static assets into motion graphics

## Acceptance Criteria

- **Given** a dependency chain where an image prompt feeds a video prompt
  **When** the dependency is resolved with `collapse: file`
  **Then** the generated image path is substituted into the video prompt

- **Given** the video prompt references the dependency alias as an attachment
  **When** the Veo or Grok Video API is called
  **Then** the image is included as the base frame for image-to-video generation

## Notes
Combines dependency resolution with attachment handling. The generated image becomes a `role: base` attachment for the video prompt.
