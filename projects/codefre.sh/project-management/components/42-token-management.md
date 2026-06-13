# Token Management

| Field | Value |
|-------|-------|
| **ID** | `token-management` |
| **Category** | Domain-Specific |
| **Used In** | 24-Organization Settings, 37-API Token Management |

## Description

CRUD interface for API tokens. Shows token list (name, role, created, expires, last used — never raw value). Create form with name, role picker, expiry. One-time token reveal on creation. Revoke and rotate actions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Token list section within Organization Settings |
| **Expanded** | Full-page token management view |

## Props / Configuration

- `tokens` — Array of { name, role, createdAt, expiresAt, lastUsedAt }
- `onCreate` — Callback with name, role, expiry; returns raw token value
- `onRevoke` — Callback to invalidate a token
- `onRotate` — Callback to revoke + replace atomically
- `roles` — Available roles (editor, viewer, ci)

## Interactions

- Create new token; raw value shown once in a copy-able field
- Revoke compromised tokens immediately
- Rotate: revoke old + issue replacement in one action
- Token value never shown after creation
