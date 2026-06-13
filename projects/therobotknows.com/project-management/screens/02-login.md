# Login Screen

| Field | Value |
|-------|-------|
| **ID** | login |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | US-002, US-006 |

## Description

Authentication screen for existing users to log in with credentials or social login.

## Key Components

- **Email Field** — Email input for authentication (US-002)
- **Password Field** — Password input with show/hide toggle (US-002)
- **Login Button** — Primary action to authenticate (US-002)
- **Forgot Password Link** — Navigation to password reset flow (US-006)
- **OAuth Buttons** — Google and Discord login options (US-003)
- **Error Message** — Invalid credentials or account locked notification (US-002)
- **Sign Up Link** — Navigation to registration (US-002)

## Interactions

- User enters credentials and submits
- System validates against stored bcrypt hashes
- Locks account after 5 failed attempts (15 minutes)
- Shows generic error messages (no account enumeration)
- OAuth flow bypasses email verification
- Redirects to Dashboard on success

## Navigation

- Accessible from: Landing page, sign-up screen, email verification
- Links to: Dashboard (success), Password Reset (forgot password), Sign Up (new user)