# Auth & Signup Page

| Field | Value |
|-------|-------|
| **ID** | `auth-signup-page` |
| **Type** | Storyboard |
| **Category** | Onboarding |
| **User Stories** | US-076 |

## Description

Authentication entry point supporting OAuth sign-up/sign-in via GitHub and Google. Clean, minimal interface with provider buttons, error handling for failed auth flows, and redirect to onboarding for new users.

## Key Components

- **OAuth provider buttons** — GitHub and Google sign-in buttons with provider icons (US-076)
- **Error message banner** — Displays auth failure reasons (account exists, provider error, etc.) (US-076)
- **Terms acceptance** — Checkbox or implicit acceptance notice for ToS and privacy policy (US-076)
- **Loading state** — Spinner/skeleton during OAuth redirect flow (US-076)

## Interactions

- Click OAuth provider to initiate sign-in flow
- Handle redirect back from OAuth provider
- Display error and retry on failure
- Redirect to onboarding for first-time users

## Navigation

- Accessible from: Landing page, any unauthenticated state
- Links to: Onboarding flow (new users), my tasks dashboard or agent dashboard (returning users)
