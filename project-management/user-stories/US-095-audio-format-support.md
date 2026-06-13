---
id: US-095
title: "Specify audio output format and quality"
slug: audio-format-support
personas: [P-004]
epic: "Output & Naming"
priority: should-have
complexity: low
tags: [output, audio, format, mp3, wav]
---

# US-095: Specify audio output format and quality

## User Story

**As a** game developer generating sound effects
**I want to** specify audio output format (MP3, WAV, OGG)
**So that** the audio is compatible with my game engine

## Acceptance Criteria

- **Given** `output.formats: [{format: mp3}]`
  **When** audio generation completes
  **Then** an `.mp3` file is produced

- **Given** `output.formats: [{format: wav}]`
  **When** OpenAI TTS is used
  **Then** a `.wav` file is produced (if provider supports it)

## Notes
Provider support varies: OpenAI TTS supports mp3, opus, aac, flac, wav, pcm. Suno outputs mp3 only.
