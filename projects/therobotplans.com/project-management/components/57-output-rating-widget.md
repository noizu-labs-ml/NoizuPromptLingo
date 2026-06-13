# Output Rating Widget

| Field | Value |
|-------|-------|
| **ID** | `output-rating-widget` |
| **Category** | AI-Specific Components |
| **Used In** | 68-Agent Output Rating, 70-Eval Dashboard |

## Description

Inline thumbs up/down widget appearing on agent outputs with optional feedback text field

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Minimal thumbs icons at output footer |
| **Compact** | Rating with optional feedback expand |

## Props / Configuration

- `outputId` — string
- `onRate` — callback(positive|negative)
- `onFeedback` — optional text callback
- `keyboardShortcut` — string

## Interactions

- click thumbs up/down
- expand for text feedback
- keyboard shortcut to rate
- aggregate into eval dashboard
