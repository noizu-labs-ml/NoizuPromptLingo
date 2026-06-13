# API Key Card

| Field | Value |
|-------|-------|
| **ID** | `api-key-card` |
| **Category** | Account Settings |
| **Used In** | S-23 Account Settings (API Keys Section) |

## Description

Display card for a single API key. Shows the key label, masked key value with a copy affordance, creation date, last-used timestamp, scope badges, and a revoke button. Does not re-display the full key after initial creation.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Label, masked key, status badge, and revoke icon — used in a dense list of multiple keys |
| **Expanded** | Full card with all metadata fields, scope badge row, copy button, and labeled revoke button |

## Props / Configuration

- `keyId` — Unique identifier for the API key record
- `label` — User-defined name for the key (e.g., "Obsidian Plugin", "n8n Automation")
- `maskedValue` — Partially masked key string for display (e.g., `trk_sk_••••••••4f2a`)
- `scopes` — Array of scope strings (e.g., `["read:entries", "write:entries", "read:universes"]`)
- `createdAt` — ISO timestamp of key creation
- `lastUsedAt` — ISO timestamp of most recent API call using this key; `null` if never used
- `isActive` — Boolean; inactive/revoked keys render in a muted style
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onRevoke` — Callback invoked when user confirms revocation; receives `keyId`
- `onCopy` — Callback invoked when user copies the masked value (for analytics)

## Interactions

- Copy button copies the masked value to clipboard and shows a brief "Copied" tooltip confirmation
- Note: the full key is only shown once at creation time in a separate "New Key Created" modal; this card never reveals it
- Revoke button opens a confirmation dialog warning that the action is irreversible and any integrations using this key will break
- After revocation the card renders with an "Revoked" badge and all actions disabled; card remains visible for 30 days then is purged
- Scope badges are color-coded: read scopes in blue, write scopes in amber, admin scopes in red
- Last Used timestamp shows relative time (e.g., "3 days ago") with absolute date in a tooltip
- "Never Used" renders in muted text when `lastUsedAt` is null
