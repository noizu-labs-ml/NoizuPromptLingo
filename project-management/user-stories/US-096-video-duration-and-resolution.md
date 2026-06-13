---
id: US-096
title: "Specify video duration and resolution"
slug: video-duration-and-resolution
personas: [P-004]
epic: "Output & Naming"
priority: should-have
complexity: low
tags: [output, video, duration, resolution]
---

# US-096: Specify video duration and resolution

## User Story

**As a** content creator producing social media clips
**I want to** control video duration and resolution
**So that** clips meet platform requirements (e.g., 15s max for Instagram)

## Acceptance Criteria

- **Given** `provider_options: { durationSeconds: 8 }` for Veo
  **When** video is generated
  **Then** an 8-second clip is produced

- **Given** `provider_options: { resolution: "720p" }`
  **When** video is generated
  **Then** 720p resolution is used

## Notes
Duration limits vary by provider. Veo: 4-8s. Grok: 1-15s. Resolution options: 480p, 720p, 1080p, 4k.
