# Prompt Body Editor

| Field | Value |
|-------|-------|
| **ID** | `prompt-body-editor` |
| **Category** | Input & Forms |
| **Used In** | 05-Prompt Detail, 12-Rubric Detail |

## Description

Rich text editor for prompt content with syntax highlighting for template variables (`{{var}}`), Jinja-style loops/conditionals (`{% for %}` / `{% if %}`), and inline variable validation. Supports preview mode showing rendered output with sample bindings.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Primary editing area taking most of the page width |

## Props / Configuration

- `content` — Prompt body text
- `onChange` — Callback on content change
- `variables` — Declared template variables for autocomplete and validation
- `previewBindings` — Sample variable values for rendered preview
- `showPreview` — Toggle rendered preview mode
- `syntaxHighlight` — Highlight `{{vars}}` and `{% tags %}`

## Interactions

- Type prompt content with syntax highlighting
- Autocomplete variable names on `{{` trigger
- Toggle preview to see rendered output with sample values
- Validation warnings for undeclared variables
