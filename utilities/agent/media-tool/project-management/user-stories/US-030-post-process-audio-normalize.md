---
id: US-030
title: "Post-process: normalize audio loudness"
slug: post-process-audio-normalize
personas: [P-004]
epic: "Post-Processing"
priority: could-have
complexity: medium
tags: [post-processing, audio, normalize, ffmpeg]
---

# US-030: Post-process: normalize audio loudness

## User Story

**As a** game developer generating soundtracks
**I want to** normalize audio loudness to a target LUFS
**So that** all game audio plays at consistent volume levels

## Acceptance Criteria

- **Given** a post-processing step `action: normalize` with `loudness_lufs: -14`
  **When** audio generation completes
  **Then** the audio file is normalized to -14 LUFS using ffmpeg

## Notes
Requires ffmpeg. Uses loudnorm filter for EBU R128-compliant normalization.
