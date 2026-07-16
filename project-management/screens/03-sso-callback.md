# SSO Callback

| Field | Value |
|-------|-------|
| **ID** | `sso-callback` |
| **Type** | Storyboard |
| **Category** | Public & Onboarding |
| **User Stories** | US-040 |

## Description

Transient, non-interactive screen at `/auth/sso-callback` that receives the OIDC provider's redirect, exchanges the auth code for a session, and forwards the user into the app. Modeled as a storyboard since it's a brief automated handoff state rather than a page users linger on.

## Key Components

- **Auth Exchange Spinner** — indicates token exchange in progress (US-040)
- **Callback Error State** — shown if code exchange fails (invalid state, expired code) (US-040)
- **Redirect Timer** — auto-forwards on success

## Interactions

- Screen mounts, immediately posts the auth code to the backend, then redirects on success (US-040)
- On failure, presents a retry link back to Login (02)

## Navigation

- Accessible from: Login (02) or Registration (Invite) (04) SSO redirect
- Links to: Organization Picker (06) on success, Login (02) on failure
