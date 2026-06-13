# Dispute Initiation Form

| Field | Value |
|-------|-------|
| **ID** | `dispute-initiation-form` |
| **Category** | Domain-Specific |
| **Used In** | 22-Dispute Resolution Page |

## Description

Guides a party through filing a dispute: selecting a reason, entering supporting evidence, uploading files, and submitting within the allowed time window. Displays a countdown to the filing deadline and indicates any payment hold in effect. Also renders an arbitrator resolution view when accessed with elevated permissions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full dispute page with reason selector, evidence fields, file upload, time window countdown, and submission action |

## Props / Configuration

- `disputeType` — Category of dispute (quality | payment | misconduct | other)
- `reasons[]` — Available reason options for the selected dispute type
- `onSubmit` — Callback invoked with the completed dispute payload on submission
- `timeWindowExpiry` — ISO timestamp of the filing deadline; drives countdown display
- `executionContext` — Associated execution or task record for pre-filling context fields
- `arbitratorMode` — When true, renders the resolution interface instead of the filing interface

## Interactions

- Select a reason from the categorized reason list to unlock evidence fields
- Enter free-text evidence and attach supporting files
- Submit within the countdown window; form is disabled after expiry
- Arbitrator view enables entering a resolution decision and notifying both parties
