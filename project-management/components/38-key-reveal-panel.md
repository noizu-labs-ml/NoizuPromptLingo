# Key Reveal Panel

| Field | Value |
|-------|-------|
| **ID** | `key-reveal-panel` |
| **Category** | Modals & Overlays |
| **Used In** | 29-Security & API Keys, 31-Integrations & Webhooks |

## Description

One-time display panel for freshly generated secrets such as API keys or webhook signing secrets. Presents the key value with a copy button and a clear warning that the value cannot be retrieved again after dismissal.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline panel embedded in the page with masked value, copy button, and warning text |
| **Expanded** | Modal overlay with prominent warning header, full key display, copy button, and acknowledge-to-close control |

## Props / Configuration

- `keyValue` — the secret string to display
- `keyType` — label for the key type (e.g., `"API Key"`, `"Webhook Secret"`)
- `onCopy` — callback invoked when the copy button is clicked
- `onAcknowledge` — callback invoked when the user confirms they have saved the key
- `showOnce` — when `true`, the panel cannot be reopened after dismissal

## Interactions

- Copy button writes `keyValue` to the clipboard and calls `onCopy`; button label changes to "Copied" briefly
- Acknowledge button (or checkbox) enables the dismiss control and calls `onAcknowledge`
- Once dismissed with `showOnce` true, the key value is replaced with a masked placeholder permanently
