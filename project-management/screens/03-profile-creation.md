# Profile Creation

| Field | Value |
|-------|-------|
| **ID** | `profile-creation` |
| **Type** | Storyboard |
| **Category** | Authentication & Onboarding |
| **User Stories** | US-003 |

## Description

Post-OAuth profile setup form. Collects display name and avatar to complete account creation. Blocks platform interaction until profile is complete, with a skip option that prompts later.

## Key Components

- **Display name input (3-30 chars, alphanumeric + spaces)** — Text field for user's visible name with live character validation (US-003)
- **Avatar upload control (max 2MB, JPG/PNG/WebP)** — File picker for profile image with format and size constraints (US-003)
- **Avatar preview (resized to 256x256)** — Shows uploaded image cropped/resized to final display dimensions (US-003)
- **Inline validation errors** — Real-time feedback on invalid name characters or oversized files (US-003)
- **Skip button** — Proceeds without completing profile, prompts later (US-003)
- **Submit button** — Finalizes profile and advances to onboarding (US-003)

## Interactions

- Type name → inline validation
- Upload avatar → preview
- Skip → proceed with default
- Submit → create profile

## Navigation

- Accessible from: Login/Signup (02) for new users
- Links to: Onboarding Flow (05)
