# Resource Creation

| Field | Value |
|-------|-------|
| **ID** | `resource-creation` |
| **Type** | Storyboard |
| **Category** | Resources |
| **User Stories** | US-023, US-031 |

## Description

Form for creating new resources (prompts, skills, MCP configs). Collects name, description, content, type, model compatibility, and tags. Validates all fields and sets initial version to v1.0.0.

## Key Components

- **Resource Type Selector** — Prompt, Skill, MCP Config (US-023)
- **Name Input** — 5-100 characters (US-023)
- **Description Textarea** — 10-500 characters (US-023)
- **Content Textarea** — 10-10000 characters, markdown (US-023)
- **Model Compatibility Selector** — GPT-4, Claude, etc. for Prompt type (US-023)
- **Compatibility Tag Input** — Models, MCP servers, frameworks (US-031)
- **Version Indicator** — v1.0.0 on creation (US-023)
- **Inline Validation Errors** — Length and format checks

## Interactions

- Select type; fill content; add tags; preview markdown; submit

## Navigation

- Accessible from: Any authenticated page via "Create Resource"
- Links to: Resource Detail (26) after creation
