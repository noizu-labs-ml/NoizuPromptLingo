# Confirmation Dialog

| Field | Value |
|-------|-------|
| **ID** | `confirmation-dialog` |
| **Category** | Modals & Overlays |
| **Used In** | 13-Space Settings, 14-Space Members, 17-Thread View, 23-Agent Configuration, 41-Settings |

## Description

Reusable confirmation modal for destructive or irreversible actions. Supports text-input confirmation (e.g., typing "TRANSFER"), warning messages, and cascading impact display.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** — Title + message + Confirm/Cancel buttons |
| **Expanded** | Title + warning + impact list + text input confirmation |

## Props / Configuration

- `title` — Dialog heading
- `message` — Warning message
- `confirmText` — Required text input (e.g., "DELETE")
- `impact` — List of affected items
- `confirmLabel` — Button text
- `destructive` — Red button styling

## Interactions

- Type confirmation text → enable confirm button
- Click confirm → execute action; click cancel → dismiss
