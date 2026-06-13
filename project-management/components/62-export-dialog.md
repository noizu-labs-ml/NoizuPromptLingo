# Export Dialog

| Field | Value |
|-------|-------|
| **ID** | `export-dialog` |
| **Category** | Modals & Overlays |
| **Used In** | 04-Weekly Review, 16-Gantt View, 19-Client Report Generator, 29-Deploy Changelog, 55-Agent Audit Log, 62-Prompt Comparison, 66-Prompt Export |

## Description

Format selection dialog for exporting content as PDF, markdown, JSON, CSV, or sending via email/Slack

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Format selector with export button |
| **Expanded** | Full dialog with format, scope, and delivery options |

## Props / Configuration

- `formats` — available format array
- `deliveryChannels` — email|slack|download
- `scope` — filter options
- `onExport` — callback

## Interactions

- select format
- choose delivery method
- configure scope/filter
- preview before export
