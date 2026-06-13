# Prompt Library

| Field | Value |
|-------|-------|
| **ID** | `prompt-library` |
| **Type** | Primary |
| **Category** | Prompt Management |
| **User Stories** | US-009, US-010, US-050 |

## Description

Browsable library of all prompts in the organization. Shows published status, usage count (how many nodes reference each prompt), and supports search/filter. Entry point for creating new prompts and viewing prompt details.

## Key Components

- **Prompt table** — List with name, description, status (draft/published), usage count, last published date (US-009, US-050)
- **Search bar** — Typeahead search over name and description (US-050)
- **Tag filter** — Filter by label/tag (US-050)
- **New Prompt button** — Opens prompt creation form (US-009)
- **"Use this prompt" action** — Returns to originating node editor with prompt attached (US-050)

## Interactions

- Click "New Prompt" to create a new prompt head
- Search/filter to find prompts
- Click a prompt row to open Prompt Detail
- "Use this prompt" navigates back to Graph Editor with prompt attached

## Navigation

- Accessible from: Global sidebar, Graph Editor (prompt picker)
- Links to: Prompt Detail (click row)
