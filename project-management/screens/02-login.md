# Login

| Field | Value |
|-------|-------|
| **ID** | `login` |
| **Type** | Primary |
| **Category** | Public & Onboarding |
| **User Stories** | US-040 |

## Description

Authentication entry point at `/login` where returning users start an OIDC/SSO sign-in. Presents the org-agnostic login form/SSO button; successful authentication redirects through the SSO Callback flow before landing in the app shell.

## Key Components

- **SSO Login Button** — initiates the OIDC redirect (US-040)
- **Login Error Banner** — surfaces auth failures (expired session, provider errors)
- **Loading Spinner Overlay** — shown during redirect handoff
- **Public Nav Bar** — shared with the Landing page

## Interactions

- User clicks the SSO Login Button → browser redirects to the identity provider, then to SSO Callback (03) (US-040)
- Failed login shows an inline Login Error Banner with a retry action

## Navigation

- Accessible from: Landing (01), direct URL, expired-session redirects from anywhere in the app
- Links to: SSO Callback (03)
