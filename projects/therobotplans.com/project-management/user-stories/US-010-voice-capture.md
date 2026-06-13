---
id: US-010
title: "Voice-to-item capture"
personas: [alex-russo]
domain: inbox
priority: low
mvp_phase: "v0.4"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want voice-to-item capture using speech recognition for hands-free task creation so that I can capture tasks while cooking, driving, or exercising without needing to type.

## Acceptance Criteria

- [ ] A microphone button in the capture modal (and mobile PWA) activates speech-to-text transcription
- [ ] Transcribed text is parsed for inline metadata the same way typed text is (tags, dates, projects)
- [ ] The user can review and edit the transcription before submitting to the inbox
- [ ] Voice capture works in noisy environments with reasonable accuracy (leveraging browser Web Speech API or a cloud STT provider)
- [ ] A voice-command mode supports structured input (e.g., "Add a task called 'review contracts' due Friday tagged legal")

## Notes

Voice capture is a power-user and accessibility feature. The structured voice-command mode is ambitious but aligns with the AI-native philosophy — the platform should understand natural language intent, not just transcribe words. Consider Whisper API for higher accuracy than browser-native STT. This depends on the capture infrastructure from US-006 and US-007.
