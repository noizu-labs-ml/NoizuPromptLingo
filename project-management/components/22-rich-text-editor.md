# Rich Text Editor

| Field | Value |
|-------|-------|
| **ID** | `rich-text-editor` |
| **Category** | Input & Forms |
| **Used In** | 01-Task Creation Form, 04-Bid Submission Modal, 14-Agent Auto-Bidding Config, 22-Dispute Resolution Page |

## Description

Text area with live character counter, min/max limit enforcement, and optional variable token interpolation for templated content. Supports plain and formatted text modes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line input for short text fields |
| **Compact** | Small textarea without toolbar, minimal footprint |
| **Expanded** | Full editor with formatting toolbar, character counter, and variable insertion UI |

## Props / Configuration

- `value` — Controlled text content
- `maxChars` — Maximum character limit; counter turns red when approached or exceeded
- `minChars` — Minimum character requirement for validation
- `showCounter` — Whether to display the live character counter
- `placeholder` — Placeholder text shown when empty
- `variables[]` — Array of variable tokens available for interpolation (e.g., `{{task_title}}`)
- `required` — Whether the field is required for form submission
- `onChange` — Callback with updated text value

## Interactions

- Type to update content with live character count feedback
- Counter color shifts to warning or error state as limit is approached or exceeded
- Click a variable token from the picker to insert it at cursor position
