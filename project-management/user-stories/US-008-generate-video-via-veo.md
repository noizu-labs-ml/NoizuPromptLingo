---
id: US-008
title: "Generate video via Veo or Grok Video"
slug: generate-video-via-veo
personas: [P-004]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [video, veo, grok, async]
---

# US-008: Generate video via Veo or Grok Video

## User Story

**As a** content creator
**I want to** generate short video clips from text descriptions
**So that** I can produce promo videos and social media clips

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: video`, `service: veo`
  **When** I run generation
  **Then** an `.mp4` file is produced after async polling

- **Given** a `.media.prompt` with `service: grok-video`
  **When** I run generation
  **Then** an `.mp4` file is produced with the specified duration and resolution

- **Given** a video prompt with an attachment `role: base`
  **When** generation runs
  **Then** the base image is used as the starting frame for image-to-video

## Notes
Both Veo and Grok Video are async. Veo shares GEMINI_API_KEY with image provider.
