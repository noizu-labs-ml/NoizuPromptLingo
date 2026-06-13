# Agent-Generated Checklist Review

| Field | Value |
|-------|-------|
| **ID** | `agent-generated-checklist-review` |
| **Type** | Modal |
| **Category** | Checklists & Processes |
| **User Stories** | US-066 |

## Description

Review modal for AI-suggested contextual checklists. Agent generates checklist items based on item type, project context, and historical patterns. User reviews with confidence scores before approving.

## Key Components

- **Suggested checklist items** — AI-generated checklist tailored to context
- **Confidence scores** — Per-item confidence that this check is relevant
- **Rationale hover** — Hover/click for why agent suggested each item
- **Approve/modify/reject** — Per-item and bulk actions
- **Audit entry** — Records the review decision

## Interactions

- Review AI suggestions with confidence indicators
- Hover for rationale on each suggestion
- Accept, modify, or reject individual items
- Bulk approve all high-confidence items
- Modified items are tracked as human-edited

## Navigation

- Triggered from: Item creation, Workflow transition
- Outputs to: Checklist attached to item
