# Quick Capture Modal

| Field | Value |
|-------|-------|
| **ID** | `quick-capture-modal` |
| **Type** | Modal |
| **Category** | Inbox & Capture |
| **User Stories** | US-006, US-010 |

## Description

Global keyboard-triggered overlay (Cmd+K or configurable shortcut) for rapid item capture. Supports inline metadata syntax (e.g., `#project @priority !due-date`) and voice input via microphone button. Appears from any screen.

## Key Components

- **Text input** — Single-line expanding input with inline metadata parsing
- **Inline metadata parser** — Recognizes `#project`, `@priority`, `!date` syntax in real-time
- **Voice capture button** — Microphone icon triggers speech-to-text transcription
- **Submit button** — Sends to inbox (Enter key shortcut)
- **Multi-line toggle** — Expand to multi-line for longer notes

## Interactions

- Global shortcut opens overlay from any screen
- Type text with optional metadata syntax
- Voice button records and transcribes
- Enter submits; Escape dismisses
- Parsed metadata shown as tag chips below input
- No project assignment required — goes to inbox by default

## Navigation

- Triggered from: Global keyboard shortcut (any screen)
- Outputs to: Inbox
