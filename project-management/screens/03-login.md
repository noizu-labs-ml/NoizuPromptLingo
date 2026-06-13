# Login

| Field | Value |
|-------|-------|
| **ID** | `login` |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | INK-002, INK-003 |

## Description

Authentication screen for returning users. Supports email/password and Google OAuth with account lockout protection after repeated failures.

## Key Components

- **Login Form** — Email and password fields with "Remember me" option (INK-002)
- **OAuth Button** — "Continue with Google" for returning OAuth users (INK-003)
- **Forgot Password Link** — Navigates to password reset flow (INK-002)
- **Lockout Message** — Displayed after 5 failed attempts with cooldown timer (INK-002)

## Interactions

- Form submits on Enter or button click
- Failed login shows inline error with remaining attempts
- Account lockout displays countdown timer before retry
- Successful login redirects to Projects Dashboard

## Navigation

- Accessible from: Landing page, any unauthenticated route
- Links to: Projects Dashboard (on success), Signup, Password Reset
