# Signup

| Field | Value |
|-------|-------|
| **ID** | `signup` |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | INK-001, INK-003 |

## Description

Account creation screen supporting email/password registration and Google OAuth. Entry point for new users converting from the landing page CTA.

## Key Components

- **Signup Form** — Email, password, confirm password fields with real-time validation (INK-001)
- **Password Strength Indicator** — Visual meter showing password strength requirements (INK-001)
- **OAuth Button** — "Continue with Google" single-click OAuth flow (INK-003)
- **Verification Banner** — Post-submission confirmation directing user to check email (INK-001)

## Interactions

- Form validates email format and password strength in real-time
- OAuth redirects to Google consent then back to onboarding
- Account linking modal appears if OAuth email matches existing account (INK-003)
- Successful signup redirects to onboarding wizard

## Navigation

- Accessible from: Landing page CTA, Login page "Create account" link
- Links to: Onboarding Wizard, Login, Email Verification pending state
