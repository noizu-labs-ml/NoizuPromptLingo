# Tag Input

| Field | Value |
|-------|-------|
| **ID** | `tag-input` |
| **Category** | Input & Forms |
| **Used In** | 05-Inbox, 06-Quick Capture Modal, 08-Personal Lists, 11-Archive, 22-Bug Report Form, 63-Prompt Tagging |

## Description

Multi-value tag input with autocomplete, create-new capability, and visual chips

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Chips displayed inline with add button |
| **Compact** | Input field with chip display below |

## Props / Configuration

- `tags` — array of strings
- `onChange` — callback
- `suggestions` — autocomplete source
- `allowCreate` — boolean
- `maxTags` — number

## Interactions

- type to search existing tags
- Enter to add
- backspace to remove last
- click X on chip to remove
