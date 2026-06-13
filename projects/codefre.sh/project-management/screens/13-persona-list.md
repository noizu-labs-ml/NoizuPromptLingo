# Persona List

| Field | Value |
|-------|-------|
| **ID** | `persona-list` |
| **Type** | Primary |
| **Category** | Persona Management |
| **User Stories** | US-035, US-055, US-116 |

## Description

Lists all personas in the organization with name, tone tag, and version info. Supports creating new personas, importing from starter library, and browsing the marketplace.

## Key Components

- **Persona table** — Name, slug, tone tag, description, current version, published status
- **New Persona button** — Opens persona creation form (US-035)
- **Import from Library button** — Opens built-in starter library browser (US-055)
- **Marketplace button** — Opens community persona marketplace (US-116)

## Interactions

- Click "New Persona" to create a persona
- Click a row to open Persona Detail
- Import from starter library (deep copy into org)
- Browse marketplace for community personas

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Persona Detail (click row), Persona Library Modal, Persona Marketplace
