# Moderation Queue Table

| Field | Value |
|-------|-------|
| **ID** | `moderation-queue-table` |
| **Category** | Tables & Lists |
| **Used In** | 39-Moderation Queue |

## Description

Structured table for moderation reports with columns for content type, report reason, reporter, space, timestamp, and priority. Supports filtering, sorting, and bulk actions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** — Table with key columns only |
| **Expanded** | Full table with all columns + action buttons |

## Props / Configuration

- `columns` — Configurable column display
- `filterBySpace` — Space filter
- `filterByPriority` — Priority filter
- `tabs` — Pending / Resolved

## Interactions

- Sort columns; filter by space/priority; select rows for bulk action
- Click row → Report Detail (40)
