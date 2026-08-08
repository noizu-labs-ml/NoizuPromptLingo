# Instructions (Prompt Templates)

| Field | Value |
|-------|-------|
| **ID** | `instructions-prompt-templates` |
| **Type** | Primary |
| **Category** | Agent Infrastructure |
| **User Stories** | None — supporting screen for agent tool-tailoring workflows (see US-005 on Session Detail, screen 21) |

## Description

Library of versioned, parameterized prompt templates ("Instructions") at `/app/[orgId]/instructions`. Rendering an instruction with parameters spawns sub-agents to carry out the resulting prompt.

## Key Components

- **Instruction Template List** — versioned templates with parameter schemas
- **Template Editor** — prompt body and parameter definitions
- **Version History Selector** — switches between saved template versions
- **Render & Spawn Button** — renders a template with supplied parameters and spawns the resulting sub-agent run

## Interactions

- User edits a template in the Template Editor and saves → a new version is appended, selectable via the Version History Selector
- User fills parameters and clicks Render & Spawn Button → a sub-agent run launches with the rendered prompt

## Navigation

- Accessible from: Org Dashboard (17), Session Detail (21)
- Links to: Session Detail (21) (spawned sub-agent runs attach to the originating session)
