# Data Table

| Field | Value |
|-------|-------|
| **ID** | `data-table` |
| **Category** | Tables & Lists |
| **Used In** | 11-Archive, 21-Template Library, 24-Bug SLA Dashboard, 40-ADR Index, 41-Runbook Manager, 44-Checklist Library, 55-Agent Audit Log, 63-Prompt Tagging, 67-Prompt Audit Trail |

## Description

Multi-column sortable table with inline actions, bulk select, and configurable columns

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Minimal columns, dense rows |
| **Expanded** | Full columns with inline actions |
| **Full_Page** | Full-page table with pagination |

## Props / Configuration

- `columns` — array of column definitions
- `data` — row array
- `sortable` — boolean
- `selectable` — boolean
- `actions` — per-row action array
- `pagination` — config

## Interactions

- sort by column header click
- multi-select rows
- inline row actions
- bulk actions on selection
- keyboard navigation
