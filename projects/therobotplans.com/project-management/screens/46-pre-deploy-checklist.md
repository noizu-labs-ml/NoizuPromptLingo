# Pre-Deploy Checklist

| Field | Value |
|-------|-------|
| **ID** | `pre-deploy-checklist` |
| **Type** | Modal |
| **Category** | Checklists & Processes |
| **User Stories** | US-068 |

## Description

Auto-populated deploy gate checklist combining automated verification items (CI pass, tests green, no P0 bugs) with manual check-offs (stakeholder approval, docs updated). Blocks deploy until complete.

## Key Components

- **Auto-check items** — Automatically verified conditions (green check or red X)
- **Manual check items** — Human verification checkboxes
- **CI integration status** — Real-time CI pipeline status inline
- **Deploy gate indicator** — Overall pass/fail for the deploy gate
- **Override action** — Bypass with mandatory reason (audited)
- **Persist as record** — Save checklist state as audit artifact

## Interactions

- Auto-items verify in real-time
- Manual items require human check-off
- Deploy blocked until all items pass (or override)
- Override requires reason and creates audit record
- Checklist instance saved for compliance

## Navigation

- Triggered from: Deploy action, Pipeline completion
- Links to: Deploy Approval Modal, Pipeline Status
