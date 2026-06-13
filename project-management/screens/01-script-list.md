# Script List

| Field | Value |
|-------|-------|
| **ID** | `script-list` |
| **Type** | Primary |
| **Category** | Script Authoring |
| **User Stories** | US-001, US-006, US-007, US-044, US-046, US-047 |

## Description

The main listing page for all scripts within the active organization. Entry point for creating, importing, forking, and managing scripts. Shows published/draft status, version counts, and quick actions.

## Key Components

- **Script table** — Sortable list with name, slug, status (draft/published/archived), current version, last updated (US-001)
- **New Script button** — Opens create form for name + description (US-001)
- **Import YAML button** — File upload / paste for YAML import (US-007)
- **Archive toggle** — Show/hide archived scripts (US-047)
- **Script row actions** — Fork (US-046), Archive (US-047), Export YAML (US-008)

## Interactions

- Click "New Script" to open creation form (name, description, slug)
- Click a script row to navigate to the Graph Editor
- Click "Import" to upload YAML or paste content
- Click "Fork" on a row to create a new independent script head
- Toggle "Show archived" to reveal archived scripts

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Graph Editor (click script), Script Version Diff (US-045)
