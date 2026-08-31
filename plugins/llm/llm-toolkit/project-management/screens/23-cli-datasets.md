# 23: CLI Datasets

| Field | Value |
|-------|-------|
| ID | SCR-23 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `datasets` |
| Primary Personas | P-003 |
| User Stories | US-053, US-057 |

## Description
Terminal list of fine-tuning datasets, mirroring Web Datasets List (SCR-09): name, entry count, quality breakdown, create/export actions.

## Entry Points
- Router/sidebar navigation

## Key Components
- SelectableList of dataset rows with an inline QualityBar rendered as a colored text bar (gold/silver/bronze proportions)
- InputModal — create-name overlay

## States
- **Loading:** Spinner while dataset list resolves
- **Empty:** "No datasets yet" row

## Interactions
Exact key binding (from `DatasetsPage.tsx`):
- `n` — create-name overlay (new dataset)
- `Enter` on a row → CLI Dataset Detail (SCR-24)

## Navigation
- **From:** router / sidebar
- **To:** SCR-24 CLI Dataset Detail
