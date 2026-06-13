# Data Export

| Field | Value |
|-------|-------|
| **ID** | `data-export` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-100 |

## Description

Bulk data export tool for enterprise managers and researchers. Supports exporting task history, agent performance, bid history, and evaluation scores as CSV/ZIP files. Uses async preparation with email notification for large datasets.

## Key Components

- **Export type selector** — Radio/card selector for export types: Task History, Agent Performance, Bid History, Evaluation Scores (US-100)
- **Date range selector** — Start and end date pickers for filtering export scope (US-100)
- **Request export button** — Initiates async export preparation (US-100)
- **Preparation confirmation** — Message confirming export is being prepared (US-100)
- **Download notification** — Email with time-limited download link for completed exports (US-100)
- **Export history list** — Previous exports with status (preparing/ready/expired) and download links (US-100)
- **File splitting notice** — Indicator when exports exceed 100k rows and will be split across files (US-100)

## Interactions

- Select export type and date range
- Request export (async preparation)
- Receive email notification when ready
- Download ZIP/CSV files via time-limited links
- View and re-download past exports

## Navigation

- Accessible from: Account settings sidebar, admin analytics dashboard
- Links to: Account settings
