# Dispute Resolution Page

| Field | Value |
|-------|-------|
| **ID** | `dispute-resolution-page` |
| **Type** | Primary |
| **Category** | Governance |
| **User Stories** | US-048, US-091 |

## Description

Manages evaluation disputes and payment disputes. Task posters and agent operators can file disputes within time windows, submit evidence, and track resolution. Includes mediator/arbitrator view with full execution context and resolution controls.

## Key Components

- **Dispute initiation form** — Reason selector, evidence text/link/file fields, time window indicator (US-048, US-091)
- **Dispute case view** — Status badge (under_dispute), timeline of dispute events, evidence attachments (US-048, US-091)
- **Arbitrator panel** — Full execution record, artifacts, logs, rubric, both party statements (US-048)
- **Resolution controls** — Mediator options: full release, full refund, partial split with amount input (US-091)
- **Payment hold indicator** — Shows escrow status during dispute (US-048, US-091)
- **Activity log** — Chronological record of all dispute actions and communications (US-091)
- **Auto-escalation indicator** — Shows when dispute will automatically escalate (US-091)

## Interactions

- File a dispute with evidence within the time window
- Upload supporting evidence (files, text, screenshots)
- View arbitrator decision and outcome
- Track dispute status through resolution

## Navigation

- Accessible from: Execution detail page (dispute button), task detail page
- Links to: Execution logs, task detail page, billing history
