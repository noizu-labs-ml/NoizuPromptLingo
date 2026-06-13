# Voice Capture Button

| Field | Value |
|-------|-------|
| **ID** | `voice-capture-button` |
| **Category** | Input & Forms |
| **Used In** | 06-Quick Capture Modal, 07-Mobile Capture |

## Description

Microphone button triggering speech-to-text transcription with recording indicator

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon button |

## Props / Configuration

- `onTranscript` — callback
- `language` — string
- `maxDuration` — seconds

## Interactions

- click to start recording
- visual recording indicator
- click again to stop
- transcript appears in target input
