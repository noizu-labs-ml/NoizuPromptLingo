# Quick Capture Overlay

| Field | Value |
|-------|-------|
| **ID** | `quick-capture-overlay` |
| **Category** | Modals & Overlays |
| **Used In** | 06-Quick Capture Modal |

## Description

Global keyboard-triggered overlay for rapid input capture, accessible from any screen

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Overlay with input, metadata parsing, and submit |

## Props / Configuration

- `shortcut` — key combination
- `onSubmit` — callback
- `parsers` — metadata syntax definitions
- `showVoice` — boolean

## Interactions

- global shortcut opens
- Escape dismisses
- Enter submits
- metadata parsed in real-time
