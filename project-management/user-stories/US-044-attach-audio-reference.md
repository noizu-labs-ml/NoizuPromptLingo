---
id: US-044
title: "Attach audio reference for voice cloning"
slug: attach-audio-reference
personas: [P-004]
epic: "Attachments"
priority: should-have
complexity: medium
tags: [attachments, audio-ref, voice-cloning, elevenlabs]
---

# US-044: Attach audio reference for voice cloning

## User Story

**As a** content creator producing voiceovers
**I want to** attach a reference audio clip for voice style matching
**So that** generated speech matches a target voice or speaking style

## Acceptance Criteria

- **Given** an attachment with `role: audio-ref` and an ElevenLabs prompt
  **When** the API is called
  **Then** the audio reference is included for voice style matching

- **Given** a non-audio file with `role: audio-ref`
  **When** validation runs
  **Then** a warning suggests using an audio format (mp3, wav, etc.)

## Notes
Audio references are provider-specific. ElevenLabs supports voice cloning from audio samples.
