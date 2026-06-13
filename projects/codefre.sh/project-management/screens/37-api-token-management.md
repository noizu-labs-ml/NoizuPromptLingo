# API Token Management

| Field | Value |
|-------|-------|
| **ID** | `api-token-management` |
| **Type** | Settings |
| **Category** | Tenancy & Admin |
| **User Stories** | US-096, US-097 |

## Description

Sub-section of Organization Settings for managing API tokens. Supports creating named tokens with role/expiry, viewing active tokens, and revoking/rotating compromised tokens.

## Key Components

- **Token list** — Name, role, created_at, expires_at, last_used_at (never shows raw value) (US-096)
- **Create token form** — Name, role picker (editor/viewer/ci), expiry date (US-096)
- **Token reveal** — Shown once on creation only (US-096)
- **Revoke button** — Immediately invalidates token (US-097)
- **Rotate button** — Revokes old token and issues replacement in one action (US-097)

## Interactions

- Create new tokens with name, role, and expiry
- Copy raw token value on creation (shown only once)
- Revoke compromised tokens
- Rotate tokens (revoke + replace atomically)

## Navigation

- Accessible from: Organization Settings (API Tokens section)
- Links to: Organization Settings (back)
