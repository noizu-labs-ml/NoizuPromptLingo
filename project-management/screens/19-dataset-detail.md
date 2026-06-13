# Dataset Detail

| Field | Value |
|-------|-------|
| **ID** | `dataset-detail` |
| **Type** | Primary |
| **Category** | Datasets |
| **User Stories** | US-101, US-102, US-103, US-104, US-105, US-110, US-125, US-150 |

## Description

Full management view for a single dataset. Shows entries, allows manual entry creation, attaches rubrics, triggers dataset eval runs, and manages versions.

## Key Components

- **Entry table** — Rows with entry_key, input preview, expected_output preview, tags (US-103)
- **Add Entry form** — Manual entry creation with input, expected_output, tags, notes (US-103)
- **Import entries** — CSV/JSON/JSONL upload with column mapping UI (US-104)
- **Default rubric picker** — Attach a rubric version for eval scoring (US-110)
- **Publish button** — Creates immutable dataset version (US-102)
- **Version history** — Published versions with checksums (US-102)
- **Run Dataset button** — Triggers eval run against an agent (US-105)
- **Export Parquet button** — Download as Parquet file (US-150)
- **Persona fan-out toggle** — Multi-persona selection for dataset runs (US-125)

## Interactions

- Add entries manually or via import
- Edit draft entries
- Attach a default rubric
- Publish as immutable version
- Trigger dataset eval run against agent(s)
- Export as Parquet
- Browse version history

## Navigation

- Accessible from: Dataset List (click row)
- Links to: Run Detail (after triggering dataset run), Rubric Detail (rubric picker)
