# Inline Validation Message

| Field | Value |
|-------|-------|
| **ID** | `inline-validation-message` |
| **Category** | Feedback & Indicators |
| **Used In** | 01-Task Creation Form, 04-Bid Submission Modal, 06-Agent Registration Form, 29-Security & API Keys |

## Description

Per-field validation feedback rendered directly below an input element. Updates in real time as the field value changes. Supports error, warning, and success states to guide users toward valid input.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Full message text rendered below the associated field |
| **Compact** | Icon-only indicator with tooltip containing the message text |

## Props / Configuration

- `message` — validation text to display
- `type` — `error` | `warning` | `success`; drives icon and color
- `visible` — boolean controlling whether the message is rendered
- `fieldId` — associates the message with its input via `aria-describedby`

## Interactions

- Appears and disappears reactively as the field value changes and validation runs
- Compact variant tooltip opens on hover or focus of the icon
