# Confirmation Modal

| Field | Value |
|-------|-------|
| **ID** | `confirmation-modal` |
| **Category** | Modals & Overlays |
| **Used In** | 11-Archive, 30-Deploy Approval Modal, 31-Rollback Confirmation, 45-Checklist Enforcement Settings, 46-Pre-Deploy Checklist |

## Description

Action confirmation dialog with impact summary, mandatory reason field, and confirm/cancel actions

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Simple confirm/cancel with message |
| **Expanded** | Full impact assessment with mandatory reason and audit note |

## Props / Configuration

- `title` — string
- `message` — string
- `impact` — optional assessment
- `requireReason` — boolean
- `confirmLabel` — string
- `destructive` — boolean

## Interactions

- review impact before confirming
- provide mandatory reason
- confirm or cancel
- audit record created on confirm
