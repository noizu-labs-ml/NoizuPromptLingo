# Rich Text Editor

| Field | Value |
|-------|-------|
| **ID** | `rich-text-editor` |
| **Category** | Input & Forms |
| **Used In** | 04-Weekly Review, 17-Sprint Retrospective, 19-Client Report Generator, 22-Bug Report Form, 38-Post-Incident Review, 39-Wiki Editor, 41-Runbook Manager, 52-Goal Retrospective, 59-Custom Agent Builder, 65-Prompt Annotations |

## Description

Markdown-capable editor with live preview, image paste, cross-link autocomplete, and split-view mode

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line expanding text input |
| **Compact** | Multi-line editor without toolbar |
| **Expanded** | Full editor with toolbar and preview pane |
| **Full_Page** | Split-view editor with live rendered preview |

## Props / Configuration

- `value` — markdown string
- `onChange` — callback
- `placeholder` — string
- `toolbar` — boolean
- `preview` — boolean
- `crossLinkEnabled` — boolean

## Interactions

- type markdown with live preview
- paste images inline
- [[link]] autocomplete
- keyboard shortcuts for formatting
