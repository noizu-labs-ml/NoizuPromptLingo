# Password Reset

| Field | Value |
|-------|-------|
| **ID** | `password-reset` |
| **Type** | Storyboard |
| **Category** | Authentication |
| **User Stories** | INK-004 |

## Description

Multi-step password reset flow: request reset email → confirmation → set new password. Accessible from login screen for users who've forgotten credentials.

## Key Components

- **Email Input Form** — Single-field form to request reset link (INK-004)
- **Confirmation Message** — "Check your email" confirmation with resend option (INK-004)
- **New Password Form** — Password + confirm with strength indicator (INK-004)

## Interactions

- Step 1: Enter email → submit → advance to confirmation
- Step 2: Wait for email, option to resend after 60s
- Step 3: Token-validated form to set new password
- Success redirects to login with "Password updated" toast

## Navigation

- Accessible from: Login page "Forgot password?" link
- Links to: Login (on completion)
