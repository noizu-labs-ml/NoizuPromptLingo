# Audit Log Explorer

| Field | Value |
|-------|-------|
| **ID** | `audit-log-explorer` |
| **Type** | Primary |
| **Category** | SafeMCP / Audit |
| **User Stories** | US-007, US-019, US-021, US-022, US-023, US-024, US-025 |

## Description

Queryable interface for immutable audit records. Filter by caller, user, tool, time range, decision. Supports saved queries, export, redaction controls, and anomaly indicators.

## Key Components

- **AuditFilterPanel**
- **AuditRecordTable**
- **AuditRecordDetail**
- **PolicyEvaluationTrace**
- **SavedQueryDropdown**
- **ExportDialog**
- **AnomalyIndicator**
- **RedactionToggle**

## Interactions

- Multi-criteria filter (AND logic)
- Click record for full detail
- Save filter as named query
- Export JSON/CSV
- Toggle unredacted view (privileged)
- Click anomaly to investigate

## Navigation

- Dashboard / SafeMCP -> Audit Log Explorer
