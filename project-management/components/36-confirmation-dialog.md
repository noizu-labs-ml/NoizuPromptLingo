# Confirmation Dialog

| Field | Value |
|-------|-------|
| **ID** | `confirmation-dialog` |
| **Category** | Modals & Overlays |
| **Used In** | 07-Agent Detail Page, 09-Execution Progress Panel, 18-Tournament Detail Page, 25-Organization Settings, 29-Security & API Keys, 31-Integrations & Webhooks, 33-Admin Moderation Panel |

## Description

Blocking modal that gates destructive or irreversible actions behind explicit user confirmation. Surfaces consequences to ensure informed consent. Optionally requires a reason before the confirm button is enabled.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Simple confirm/cancel layout with title and short message |
| **Expanded** | Full modal with consequence list, optional reason textarea, and styled destructive confirm button |

## Props / Configuration

- `title` — modal heading summarizing the action
- `message` — explanatory body text
- `consequences` — array of strings listing what will happen upon confirmation
- `requireReason` — when `true`, a reason textarea must be filled before confirming
- `onConfirm` — callback invoked with optional reason string on confirmation
- `onCancel` — callback invoked on cancellation
- `confirmLabel` — label for the confirm button (default: "Confirm")
- `destructive` — when `true`, confirm button renders in destructive (red) styling

## Interactions

- Confirm button calls `onConfirm` (with reason if `requireReason` is true)
- Cancel button and backdrop click call `onCancel`
- Escape key calls `onCancel`
- When `requireReason` is true, confirm button is disabled until reason field is non-empty
