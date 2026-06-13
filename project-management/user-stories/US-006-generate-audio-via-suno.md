---
id: US-006
title: "Generate audio (music) via Suno"
slug: generate-audio-via-suno
personas: [P-004]
epic: "Core Generation"
priority: must-have
complexity: medium
tags: [audio, suno, music, async]
---

# US-006: Generate audio (music) via Suno

## User Story

**As a** game developer
**I want to** generate background music from a text description using Suno
**So that** I can create game soundtracks without musical training

## Acceptance Criteria

- **Given** a `.media.prompt` with `type: audio`, `service: suno`, and `instrumental: true`
  **When** I run generation
  **Then** an `.mp3` file is produced after async polling completes

- **Given** the Suno API returns a pending status
  **When** polling is in progress
  **Then** a progress indicator shows the polling state without blocking the terminal

## Notes
Suno is async — submit then poll. Polling interval and timeout need to be configurable.
