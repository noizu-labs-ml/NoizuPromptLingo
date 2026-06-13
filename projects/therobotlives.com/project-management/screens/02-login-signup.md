# Login / Signup

| Field | Value |
|-------|-------|
| **ID** | `login-signup` |
| **Type** | Primary |
| **Category** | Authentication & Onboarding |
| **User Stories** | US-001, US-002 |

## Description

Combined login and signup page with OAuth provider selection. Handles new user registration and returning user authentication. Displays error states for duplicate accounts, provider conflicts, and session expiry re-authentication.

## Key Components

- **"Sign up with GitHub" button** — OAuth entry point for GitHub users (US-001)
- **"Sign up with Google" button** — OAuth entry point for Google users (US-001)
- **Error message display (duplicate accounts, provider conflicts)** — Inline feedback when auth fails due to account conflicts (US-002)
- **Session expiry redirect handler** — Detects and surfaces expired session state with re-auth prompt (US-002)
- **Login/signup mode toggle** — Switches between login and registration context (US-001)

## Interactions

- Click OAuth → provider auth flow → redirect back
- Error → inline message display
- Session expired → re-authentication prompt

## Navigation

- Accessible from: Landing page (01), protected route redirects, session expiry
- Links to: Profile Creation (03) for new users, Homepage (06) for returning users
