# 09: Datasets List

| Field | Value |
|-------|-------|
| ID | SCR-09 |
| Surface | web |
| Type | dashboard |
| Category | Core |
| Route / Entry | `/datasets` |
| Primary Personas | P-003 |
| User Stories | US-053, US-057 |

## Description
Overview of every fine-tuning dataset: entry counts, gold/silver/bronze quality distribution, last-updated, and bulk export. The ML engineer's home base for turning curated conversation excerpts into training data.

## Entry Points
- Global nav "Datasets"
- "Add to dataset" flows from Thread Viewer / Thread Editor tagging actions

## Key Components
- CreateDatasetBtn — name + description dialog
- DatasetCard — name, description, entry count, quality breakdown, last updated
- QualityBar — gold/silver/bronze stacked bar (per dataset)
- BulkExportPanel — format selector (OpenAI / Anthropic / generic JSONL) + download

## States
- **Loading:** skeleton cards while `GET /api/datasets` resolves
- **Empty:** "No datasets yet" with a prompt to create one or tag a thread range
- **Error:** inline banner on create/list failure

## Interactions
- CreateDatasetBtn opens a name+description dialog, `POST /api/datasets`
- Card click → Dataset Detail (SCR-10)
- Bulk export streams a download in the selected format without opening a dataset

## Navigation
- **From:** global nav, tagging flows
- **To:** SCR-10 Dataset Detail
