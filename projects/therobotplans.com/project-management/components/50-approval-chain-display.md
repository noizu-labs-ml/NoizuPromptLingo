# Approval Chain Display

| Field | Value |
|-------|-------|
| **ID** | `approval-chain-display` |
| **Category** | Feedback & Indicators |
| **Used In** | 30-Deploy Approval Modal, 46-Pre-Deploy Checklist |

## Description

Ordered list of required approvers with approved/pending/rejected status per person

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Avatar stack with status dots |
| **Compact** | List of approvers with status badges |
| **Expanded** | Full chain with timestamps and comments |

## Props / Configuration

- `approvers` — array of {user, status, timestamp, comment}
- `requiredCount` — number

## Interactions

- click approver for their decision detail
- shows overall gate status
