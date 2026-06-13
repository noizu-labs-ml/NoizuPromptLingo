# Share Modal

| Field | Value |
|-------|-------|
| **ID** | `share-modal` |
| **Category** | Modals & Overlays |
| **Used In** | 21-Interactive Prototype, 26-Demo Preview, 30-Account Settings |

## Description

Modal for generating shareable links with configurable expiration, access control, and revoke capability. Used for demo previews, prototype sharing, and project read-only access.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline share popover with copy button |
| **Expanded** | Full modal with expiration, password, and viewer settings |

## Props / Configuration

- `url` — Generated share URL
- `expiration` — Time-limited duration (1h/24h/7d/30d/never)
- `requirePassword` — Boolean
- `viewerComments` — Boolean (enable viewer feedback widget)
- `onRevoke` — Callback to invalidate link

## Interactions

- Generate → displays URL with one-click copy
- Expiration picker configures link lifetime
- "Revoke" invalidates immediately
- Activity shows viewer engagement
