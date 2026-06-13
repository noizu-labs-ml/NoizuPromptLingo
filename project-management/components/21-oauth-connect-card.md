# OAuth Connect Card

| Field | Value |
|-------|-------|
| **ID** | `oauth-connect-card` |
| **Category** | Cards & Tiles |
| **Used In** | 02-Signup, 03-Login, 30-Account Settings |

## Description

Integration card showing OAuth provider status (connected/not connected), connected identity, and connect/disconnect actions. Used for Google, GitHub, and future provider integrations.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Provider icon + status + single action button |
| **Expanded** | Full card with connected identity details and capabilities unlocked |

## Props / Configuration

- `provider` — Provider name and icon (Google, GitHub)
- `status` — connected | disconnected | expired
- `identity` — Connected email/username (when connected)
- `capabilities` — What connecting unlocks (e.g., "Push to GitHub")

## Interactions

- "Connect" → OAuth redirect flow
- "Disconnect" → confirmation dialog
- "Re-authenticate" when token expired
- Shows what features are unlocked by connection
