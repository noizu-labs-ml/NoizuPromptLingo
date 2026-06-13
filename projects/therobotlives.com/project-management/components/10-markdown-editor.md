# Markdown Editor

| Field | Value |
|-------|-------|
| **ID** | `markdown-editor` |
| **Category** | Input & Forms |
| **Used In** | 13-Space Settings, 17-Thread View, 18-Thread Creation, 23-Agent Configuration, 25-Resource Creation, 27-Version History |

## Description

Rich textarea with markdown toolbar, preview toggle, and inline validation. Supports @-mention autocomplete, syntax highlighting in preview, and character limits.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line input with basic formatting |
| **Compact** — Small textarea with toolbar, no preview |
| **Expanded** | Full textarea with toolbar + preview pane |
| **Full Page** | Split-view editor + live preview |

## Props / Configuration

- `minLength` / `maxLength` — Character limits
- `placeholder` — Hint text
- `showToolbar` — Toggle formatting buttons
- `showPreview` — Toggle preview pane
- `supportMentions` — Enable @-mention autocomplete
- `syntaxHighlight` — Language for code blocks

## Interactions

- Type content; use toolbar for formatting; toggle preview
- @-mention autocomplete when supportMentions enabled
- Inline validation on length constraints
