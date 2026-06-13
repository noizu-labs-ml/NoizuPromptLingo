# Persona Detail

| Field | Value |
|-------|-------|
| **ID** | `persona-detail` |
| **Type** | Primary |
| **Category** | Persona Management |
| **User Stories** | US-035, US-036, US-051, US-053 |

## Description

Full editor for a persona including tone tag, system preamble prompt reference, persona-layered expectations, and version management.

## Key Components

- **Name/slug/description fields** — Basic identity (US-035)
- **Tone tag** — Free-text tag with suggestions (US-035)
- **System preamble picker** — Reference to a published prompt version for persona preamble (US-053)
- **Persona expectations** — Per-node expectations scoped to this persona (US-051)
- **Publish button** — Creates immutable persona version (US-035)
- **Version history** — Published versions with timestamps

## Interactions

- Edit persona metadata and tone
- Attach a system preamble prompt
- Declare persona-specific expectations on script nodes
- Publish as immutable version

## Navigation

- Accessible from: Persona List (click row)
- Links to: Graph Editor (via persona expectations node picker), Prompt Library (preamble picker)
