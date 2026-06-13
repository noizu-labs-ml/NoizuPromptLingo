# Email Verification

| Field | Value |
|-------|-------|
| **ID** | `email-verification` |
| **Type** | Primary |
| **Category** | Authentication & Onboarding |
| **User Stories** | US-004 |

## Description

Email verification confirmation page. Validates email ownership via unique token link. Handles expired tokens with resend option. Unverified users see a persistent verification prompt when attempting write actions.

## Key Components

- **Verification confirmation message** — Success state shown after token is validated (US-004)
- **"Resend verification email" button** — Triggers a new verification email when token expired or lost (US-004)
- **Token expired error with resend option** — Error state for stale tokens with recovery path (US-004)
- **Verification status indicator** — Shows current verification state at a glance (US-004)
- **Persistent verification banner (on other pages for unverified users)** — Global banner that blocks write actions until verified (US-004)

## Interactions

- Click email link → verify → success page
- Expired token → resend flow
- Unverified + write action → blocking prompt

## Navigation

- Accessible from: Email link
- Links to: Homepage (06) after verification, Login/Signup (02) if session lost
