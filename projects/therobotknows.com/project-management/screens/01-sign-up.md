# Sign Up Screen

| Field | Value |
|-------|-------|
| **ID** | sign-up |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | US-001 |

## Description

A registration form for new users to create an account using email and password.

## Key Components

- **Email Field** — Email input with validation (required) (US-001)
- **Password Field** — Password input with requirements display (min 8 chars, 1 uppercase, 1 number) (US-001)
- **Sign Up Button** — Primary action to create account (US-001)
- **Inline Error Messages** — Validation errors for duplicate email or password requirements (US-001)
- **Already Have Account Link** — Navigation to login screen (US-001)
- **OAuth Buttons** — Integration points for Google/Discord login (US-003)

## Interactions

- User enters email and password
- System validates password requirements in real-time
- On submit, checks for duplicate email
- Shows inline errors or redirects to email verification
- OAuth buttons redirect to provider OAuth2 PKCE flow

## Navigation

- Accessible from: Landing page, login page
- Links to: Email Verification (on success), Login (already have account), Profile Setup (post-OAuth)