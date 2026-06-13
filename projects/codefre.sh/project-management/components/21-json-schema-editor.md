# JSON Schema Editor

| Field | Value |
|-------|-------|
| **ID** | `json-schema-editor` |
| **Category** | Input & Forms |
| **Used In** | 05-Prompt Detail, 07-Agent Detail |

## Description

Structured editor for defining JSON Schema objects — used for tool/function definitions in prompts and request/response templates in agent adapters. Supports adding properties, setting types, nesting objects, and raw JSON toggle.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full panel with visual schema builder and raw JSON toggle |

## Props / Configuration

- `schema` — Current JSON Schema object
- `onChange` — Callback when schema changes
- `mode` — `visual` | `raw` (toggle between form builder and raw JSON editor)
- `context` — What the schema describes (tool parameters, request template, response template)

## Interactions

- Add/remove properties with type pickers
- Nest objects and arrays
- Toggle between visual builder and raw JSON
- Validate schema on change
