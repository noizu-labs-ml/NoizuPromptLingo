# Email Verification Gate

| Field | Value |
|-------|-------|
| **ID** | email-verification |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | US-008 |

## Description

Gate page preventing access until email is verified.

## Key Components

- **Verification Message** — Instructions to check email (US-008)
- **Resend Button** — Request new verification email (disabled 60s after click) (US-008)
- **Status Message** — Token expired or verified confirmation (US-008)
- **Request New Link Button** — For expired tokens (US-008)
- **Email Display** — Shows the email address being verified (US-008)

## Interactions

- Blocked from accessing platform features before verification
- Can resend email every 60 seconds
- Verification links valid for 24 hours
- Expired links offer option to request new one
- OAuth accounts bypass this screen
- Redirects to Profile Setup on verification

## Navigation

- Accessible from: Post-registration, login for unverified users
- Links to: Profile Setup (on success), Login (expired token)