# Connected Account Panel

| Field | Value |
|-------|-------|
| **ID** | `connected-account-panel` |
| **Category** | Data Display |
| **Used In** | 07-user-profile, 13-admin-github-integration |

## Description

A read-only summary of an external identity/connection — a user's connected OIDC provider info, or the platform's GitHub App install status. Both are informational status panels sourced from an external system rather than editable local fields.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Connection status line with provider name |

## Props / Configuration

- `provider` — source system name (OIDC provider, GitHub)
- `status` — connected/disconnected state
- `metadata` — read-only fields sourced from the external system

## Interactions

- Read-only display; no direct editing. Reconnecting or revoking, where offered, is handled by an adjacent action (e.g. a Modal Dialog or Data Table row action) rather than inline on the panel itself
