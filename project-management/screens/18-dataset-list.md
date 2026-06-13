# Dataset List

| Field | Value |
|-------|-------|
| **ID** | `dataset-list` |
| **Type** | Primary |
| **Category** | Datasets |
| **User Stories** | US-101, US-104, US-149 |

## Description

Lists all datasets in the organization with name, type (request_response/conversation), entry count, and version info. Entry point for creating, importing, and managing datasets.

## Key Components

- **Dataset table** — Name, type, entry count, current version, last updated
- **New Dataset button** — Opens dataset creation form (US-101)
- **Import button** — CSV/JSON/JSONL file import (US-104)
- **Import HuggingFace button** — Import directly from HF Hub (US-149)

## Interactions

- Click "New Dataset" to create a dataset
- Click a row to open Dataset Detail
- Import from file or HuggingFace

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Dataset Detail (click row)
