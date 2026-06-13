# Five-Whys Editor

| Field | Value |
|-------|-------|
| **ID** | `five-whys-editor` |
| **Category** | Domain-Specific |
| **Used In** | 38-Post-Incident Review |

## Description

Structured cascading question-answer editor for root cause analysis, pre-filled by AI and editable

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Cascading Q&A form with AI pre-fill |

## Props / Configuration

- `whys` — array of {question, answer}
- `aiGenerated` — boolean
- `onEdit` — callback
- `maxDepth` — number

## Interactions

- edit AI-generated answers
- add additional why levels
- mark root cause identified
