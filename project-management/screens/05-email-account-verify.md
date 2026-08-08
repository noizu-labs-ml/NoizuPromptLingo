# Email/Account Verify

| Field | Value |
|-------|-------|
| **ID** | `email-account-verify` |
| **Type** | Storyboard |
| **Category** | Public & Onboarding |
| **User Stories** | None — transitional step within the registration flow (see US-039, US-085 on screen 04) |

## Description

Brief confirmation screen at `/auth/verify` and `/auth/verify-email` shown when an account requires an additional verification step (e.g., email ownership confirmation) before it is fully activated. Bridges Registration and first successful login.

## Key Components

- **Verification Status Card** — pending/verified/expired state display
- **Resend Verification Button** — re-triggers a verification email
- **Continue to App Button** — enabled once verification completes

## Interactions

- User arrives via a verification link; screen checks token validity on mount
- Verified: shows a success state with a continue action
- Expired/invalid: offers a resend action via the Resend Verification Button

## Navigation

- Accessible from: Registration (Invite) (04), verification email link
- Links to: Organization Picker (06) once verified
