# Inline Metadata Input

| Field | Value |
|-------|-------|
| **ID** | `inline-metadata-input` |
| **Category** | Input & Forms |
| **Used In** | 06-Quick Capture Modal, 07-Mobile Capture |

## Description

Text input that parses inline syntax (#project, @priority, !date) into structured metadata shown as chips

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line with parsed chip display below |
| **Expanded** | Multi-line with metadata panel |

## Props / Configuration

- `value` — string
- `onChange` — callback
- `parsers` — syntax definitions
- `placeholder` — string

## Interactions

- type with inline syntax
- parsed metadata shown as chips in real-time
- click chip to edit
- voice input via microphone
