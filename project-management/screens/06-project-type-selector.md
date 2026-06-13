# Project Type Selector

| Field | Value |
|-------|-------|
| **ID** | `project-type-selector` |
| **Type** | Primary |
| **Category** | Onboarding |
| **User Stories** | INK-087 |

## Description

First step of project creation where users select a project category. Adapts subsequent wizard questions based on selection. Uses plain-English cards accessible to non-technical users.

## Key Components

- **Type Cards** — 4+ category options (Web App, API, Mobile App, Static Site, "Not sure yet") with icon + description (INK-087)

## Interactions

- Selecting a card advances to Pitch Input with type context
- "Not sure yet" skips type-specific questions
- Selection influences AI suggestions in later steps

## Navigation

- Accessible from: Dashboard "+ New Project", Landing page CTA (post-signup)
- Links to: Pitch Input screen
