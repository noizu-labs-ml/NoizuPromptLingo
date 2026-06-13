# Organization Settings

| Field | Value |
|-------|-------|
| **ID** | `organization-settings` |
| **Type** | Settings |
| **Category** | Tenancy & Admin |
| **User Stories** | US-039, US-040, US-064, US-071, US-096, US-097, US-131, US-132, US-142, US-143 |

## Description

Central settings page for the organization. Manages members, API tokens, freeball runner configuration, OTel retention/sampling, SSO, and audit log export.

## Key Components

- **General section** — Org name, slug (US-039)
- **Members section** — Member list with roles, invite form (email + role picker) (US-040)
- **API Tokens section** — Token list with create/revoke/rotate actions (US-096, US-097)
- **Freeball Runner section** — Runner model picker, system prompt reference, confidence thresholds (US-071, US-024)
- **OTel section** — Retention policy dropdown, storage usage widget, sampling config (US-131, US-132)
- **SSO section** — SAML/OIDC configuration (US-142)
- **Audit Log section** — Export button with date-range filter (US-143)
- **Agent Governance defaults** — Default daily cost caps, rate limits (US-064)

## Interactions

- Edit org details
- Invite members, change roles
- Create/revoke/rotate API tokens
- Configure freeball runner defaults
- Set OTel retention and sampling policies
- Configure SSO
- Export audit logs

## Navigation

- Accessible from: Global sidebar (settings gear icon)
- Links to: Member detail, API Token creation modal
