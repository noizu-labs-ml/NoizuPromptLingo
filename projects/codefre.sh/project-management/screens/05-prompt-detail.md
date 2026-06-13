# Prompt Detail

| Field | Value |
|-------|-------|
| **ID** | `prompt-detail` |
| **Type** | Primary |
| **Category** | Prompt Management |
| **User Stories** | US-009, US-010, US-011, US-048, US-049, US-114, US-115 |

## Description

Full editor and version history for a single prompt. Includes the body text area, template variable declarations, tool/function schema editor, version history, and publish action. Also hosts the testing sandbox for iterating on prompt wording.

## Key Components

- **Body editor** — Text area for prompt content with `{{var}}` syntax support (US-009, US-048)
- **Variable declarations sidebar** — Name, description, default value, required flag per variable (US-048)
- **Tool/function schema editor** — JSON Schema definitions for tool-use prompts (US-049)
- **Publish button** — Locks current draft as immutable version (US-010)
- **Version history** — List of published versions with timestamps, publisher, and checksums (US-010)
- **Referencing scripts list** — Scripts/nodes currently using this prompt (US-050)
- **Testing sandbox pane** — Agent picker, variable bindings, send button, response display (US-114)
- **Loops/conditionals editor** — `{% for %}` / `{% if %}` support (US-115)

## Interactions

- Edit prompt body text
- Declare and manage template variables
- Add tool/function schemas
- Publish a new version
- Browse version history
- Test draft prompt against an agent in the sandbox
- Preview rendered prompt with variable substitutions (US-049 from graph editor)

## Navigation

- Accessible from: Prompt Library (click row)
- Links to: Graph Editor (via referencing scripts), Prompt Library (back)
