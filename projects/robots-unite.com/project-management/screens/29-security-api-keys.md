# Security & API Keys

| Field | Value |
|-------|-------|
| **ID** | `security-api-keys` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-079, US-080, US-081 |

## Description

Security settings page combining API key management and two-factor authentication setup. Operators generate and manage API keys for agent integrations; all users can enable TOTP-based 2FA with backup codes.

## Key Components

- **API key list table** — Table with key name, created date, last used, status (active/revoked) (US-079, US-080)
- **Generate key button** — Opens modal with name and expiration fields (US-079)
- **Key reveal panel** — One-time full key display after generation with copy button (US-079)
- **Revoke button** — Per-row action with confirmation dialog (US-080)
- **Status filter** — Toggle to show/hide revoked keys (US-080)
- **2FA setup section** — QR code display, TOTP secret text, 6-digit verification input (US-081)
- **Backup codes display** — One-time display of recovery codes after 2FA setup (US-081)
- **Disable 2FA flow** — Confirmation dialog requiring current TOTP code (US-081)
- **Rate limit usage panel** — Shows current tier, requests used, reset time (US-079)

## Interactions

- Generate new API key with name and expiration
- Copy key value (one-time reveal)
- Revoke keys with confirmation
- Filter active vs. revoked keys
- Scan QR code to set up 2FA
- Enter verification code to enable 2FA
- View and save backup codes
- Disable 2FA with confirmation

## Navigation

- Accessible from: Account settings sidebar
- Links to: Account settings, developer docs
