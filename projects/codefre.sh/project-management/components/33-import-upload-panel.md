# Import Upload Panel

| Field | Value |
|-------|-------|
| **ID** | `import-upload-panel` |
| **Category** | Input & Forms |
| **Used In** | 01-Script List, 18-Dataset List, 19-Dataset Detail |

## Description

File upload interface supporting drag-and-drop or click-to-browse. Handles YAML (script import), CSV/JSON/JSONL (dataset import), and HuggingFace Hub imports. Includes format validation, column mapping UI for CSVs, and paste-from-clipboard support.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Button that opens a modal/popover with upload area |
| **Expanded** | Full panel with drag zone, format selector, and column mapping |

## Props / Configuration

- `acceptedFormats` — File types accepted (yaml, csv, json, jsonl)
- `onUpload` — Callback with parsed file content
- `columnMapping` — Show column mapping UI for CSV files
- `pasteSupport` — Enable paste-from-clipboard
- `externalSources` — Additional import sources (HuggingFace Hub)
- `validation` — Format-specific validation rules

## Interactions

- Drag and drop files onto upload zone
- Click to open file browser
- Paste content directly from clipboard
- Map CSV columns to expected fields
- Import from external sources (HuggingFace)
- Validation errors shown inline before confirming
