---
id: US-007
title: "Generate voiceover via TTS providers"
slug: generate-voiceover-via-tts
personas: [P-004]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [audio, tts, voiceover, elevenlabs, openai]
---

# US-007: Generate voiceover via TTS providers

## User Story

**As a** content creator
**I want to** generate voiceover audio from text using TTS providers
**So that** I can add narration to videos and presentations

## Acceptance Criteria

- **Given** a `.media.prompt` with `service: openai-tts` and a voice selection
  **When** I run generation
  **Then** an `.mp3` file is produced with the spoken text

- **Given** a `.media.prompt` with `service: elevenlabs` and `voice_id`
  **When** I run generation
  **Then** an `.mp3` file is produced matching the specified voice characteristics

- **Given** a `.media.prompt` with `service: qwen-tts`
  **When** I run generation
  **Then** audio is returned (possibly as URL requiring download)

## Notes
Three TTS providers with different APIs. OpenAI TTS and ElevenLabs are synchronous. Qwen TTS returns a URL.
