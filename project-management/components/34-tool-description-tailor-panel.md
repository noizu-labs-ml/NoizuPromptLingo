# Tool Description Tailor Panel

| Field | Value |
|-------|-------|
| **ID** | `tool-description-tailor-panel` |
| **Category** | AI-Specific |
| **Used In** | 21-session-detail |

## Description

Customizes a session's tool descriptions per target model/runner, with a live preview of the tailored output. Single-screen, but the model/runner-aware tailoring behavior is a distinctly AI-native, non-trivial interaction pattern in its own right.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Target model/runner selector plus tailored-description preview |

## Props / Configuration

- `targetModel` / `targetRunner` — the tailoring target
- `previewContent` — the resulting tailored tool descriptions

## Interactions

- User selects a target model/runner → the tailored description preview regenerates for that target
