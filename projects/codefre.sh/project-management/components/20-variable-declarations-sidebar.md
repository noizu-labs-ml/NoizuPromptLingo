# Variable Declarations Sidebar

| Field | Value |
|-------|-------|
| **ID** | `variable-declarations-sidebar` |
| **Category** | Input & Forms |
| **Used In** | 05-Prompt Detail, 02-Graph Editor |

## Description

Sidebar listing all declared template variables for a prompt. Each variable has name, description, default value, and required flag. Used in Prompt Detail for authoring and in Graph Editor for per-node binding.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Binding-only mode in Graph Editor node detail (name + value input per variable) |
| **Expanded** | Full declaration mode in Prompt Detail (name, description, default, required, type) |

## Props / Configuration

- `variables` — Array of { name, description, defaultValue, required, type }
- `mode` — `declare` (authoring new variables) | `bind` (providing values for existing variables)
- `bindings` — Current variable values (for bind mode)
- `onUpdate` — Callback when variables are added/edited/removed

## Interactions

- Add new variable declarations
- Edit variable metadata (description, default, required)
- In bind mode: provide values for each declared variable
- Validation: highlight unbound required variables
