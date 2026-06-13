# Confirmation Dialog

| Field | Value |
|-------|-------|
| **ID** | `confirmation-dialog` |
| **Category** | Modals & Overlays |
| **Used In** | 05-Projects Dashboard, 11-PRD Editor, 24-Agent Development, 28-Deploy, 30-Account Settings |

## Description

Standard confirmation modal for destructive or irreversible actions. Supports simple confirm/cancel and high-stakes "type to confirm" patterns. Displays consequences before action.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Simple confirm/cancel dialog |
| **Expanded** | Consequence list + "type to confirm" input for high-stakes actions |

## Props / Configuration

- `title` — Dialog heading
- `message` — Consequence description
- `confirmLabel` — Button text (e.g., "Delete", "Deploy", "Rollback")
- `variant` — default | destructive | high-stakes
- `typeToConfirm` — String user must type to proceed (for high-stakes)

## Interactions

- Simple: Confirm or Cancel
- High-stakes: Must type specified text before Confirm enables
- Escape key or backdrop click → Cancel
- Destructive variant: red-styled confirm button
