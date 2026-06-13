# Password Reset Screen

| Field | Value |
|-------|-------|
| **ID** | password-reset |
| **Type** | Modal |
| **Category** | Authentication |
| **User Stories** | US-006 |

## Description

Two-step password reset flow: request and confirm.

## Key Components

- **Email Input** — Request step: email to send reset link (US-006)
- **Request Button** — Triggers reset email send (US-006)
- **Success Message** — Generic success message (no account enumeration) (US-006)
- **New Password Fields** — Confirm step: new password and confirm (US-006)
- **Reset Button** — Confirm step: apply new password (US-006)
- **Error Message** — Invalid or expired token display (US-006)

## Interactions

- User submits email for reset request
- System sends email if account exists (generic message regardless)
- Reset link valid for 60 minutes, single-use
- User sets new password on link click
- All existing sessions invalidated
- Redirects to login on success

## Navigation

- Accessible from: Login screen (forgot password link)
- Links to: Login (on success)