# Audit Export Dialog

| Field | Value |
|-------|-------|
| **ID** | `audit-export-modal` |
| **Type** | Modal |
| **Category** | SafeMCP / Audit |
| **User Stories** | US-023 |

## Description

Configure audit log export: format (JSON/CSV), date range, size estimate. Background job with download notification.

## Key Components

- **FormatSelector**
- **DateRangeConfirmation**
- **SizeEstimate**
- **ExportProgressIndicator**

## Interactions

- Select format
- Confirm date range
- Trigger background export
- Download when ready

## Navigation

- Audit Log Explorer -> Export Modal
