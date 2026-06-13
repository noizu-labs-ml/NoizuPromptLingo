---
id: US-042
title: "Attach base image for editing or video generation"
slug: attach-base-image-for-inpainting
personas: [P-004]
epic: "Attachments"
priority: should-have
complexity: medium
tags: [attachments, base, image-to-video, inpainting]
---

# US-042: Attach base image for editing or video generation

## User Story

**As a** content creator generating videos
**I want to** attach a base image that becomes the starting frame
**So that** I can animate a static image into a video clip

## Acceptance Criteria

- **Given** a video `.media.prompt` with an attachment `role: base`
  **When** the Veo or Grok Video API is called
  **Then** the base image is included as the reference frame

- **Given** an image `.media.prompt` with `role: mask`
  **When** generation runs
  **Then** the mask guides inpainting (white = generate, black = preserve)

## Notes
Image-to-video requires a base image. Mask-based inpainting is a planned feature for image editing.
