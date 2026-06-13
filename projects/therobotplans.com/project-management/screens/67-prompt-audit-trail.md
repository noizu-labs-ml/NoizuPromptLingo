# Prompt Audit Trail

| Field | Value |
|-------|-------|
| **ID** | `prompt-audit-trail` |
| **Type** | Primary |
| **Category** | Prompt Archival & Versioning |
| **User Stories** | US-095 |

## Description

Compliance-grade append-only audit log of all prompt changes. Every change requires a mandatory rationale field. Cryptographic hash chain ensures tamper evidence. Exportable in compliance formats.

## Key Components

- **Audit log list** — Chronological log of all prompt changes
- **Actor filter** — Filter by who made the change
- **Change type filter** — Filter by type (create, edit, restore, delete)
- **Rationale field** — Mandatory reason for each change (displayed inline)
- **Hash chain verification** — Verify integrity of the audit chain
- **Export compliance format** — Export in SOC2/ISO-compatible formats

## Interactions

- Browse chronological log
- Filter by actor, change type, date range
- Click entry to see full change detail with diff
- Verify hash chain integrity
- Export for compliance audits

## Navigation

- Accessible from: Prompt management nav, Agent Audit Log
- Links to: Prompt Timeline, Agent Audit Log
