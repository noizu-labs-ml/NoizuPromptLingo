# SSO Auth Button

| Field | Value |
|-------|-------|
| **ID** | `sso-auth-button` |
| **Category** | Input & Forms |
| **Used In** | 02-login, 04-registration-invite |

## Description

Initiates the OIDC/SSO redirect handoff, either for a returning user's login or an invite-scoped registration. Identical mechanism in both places; the invite variant is additionally gated on a valid, unexpired, non-exhausted invite token.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Standard labeled button ("Log In with SSO", "Continue with SSO") |

## Props / Configuration

- `mode` — `login` \| `invite-registration`
- `inviteToken` — required when `mode` is `invite-registration`; button is disabled/hidden if the token is invalid

## Interactions

- User clicks the button → browser redirects to the identity provider, then returns via the SSO Callback flow
- Invite mode: button only renders once the invite token has been validated as active
