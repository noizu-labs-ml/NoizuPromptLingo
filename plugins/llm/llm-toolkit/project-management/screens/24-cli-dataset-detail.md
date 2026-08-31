# 24: CLI Dataset Detail

| Field | Value |
|-------|-------|
| ID | SCR-24 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `dataset-detail` (from a CLI Datasets row) |
| Primary Personas | P-003 |
| User Stories | US-054, US-055, US-056, US-057 |

## Description
Terminal entry browser for one dataset, mirroring Web Dataset Detail (SCR-10): review each entry's message sequence, set quality label, delete, and export directly to a chosen format via number-key shortcuts.

## Entry Points
- `Enter` on a row in CLI Datasets (SCR-23)

## Key Components
- SelectableList of dataset entries with inline QualitySelector
- ConfirmDialog — confirm-delete

## States
- **Loading:** Spinner while entries resolve
- **Empty:** "No entries yet" row
- **Confirm delete:** blocks navigation until confirmed/cancelled

## Interactions
Exact key bindings (from `DatasetDetailPage.tsx`):
- `d` — confirm-delete overlay for the focused entry
- `1` / `2` / `3` — export in `openai` / `anthropic` / `jsonl` format respectively

## Navigation
- **From:** SCR-23 CLI Datasets
- **To:** SCR-23 (back)
