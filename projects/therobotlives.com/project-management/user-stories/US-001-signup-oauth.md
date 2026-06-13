---
id: US-001
title: "User Signup via OAuth"
slug: "signup-oauth"
personas: [P-001, P-002, P-005]
epic: "Authentication & Signup"
priority: "must-have"
complexity: "M"
tags: [authentication, oauth, onboarding]
---

# US-001: User Signup via OAuth

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** sign up for TheRobotLives using my existing GitHub or Google account,
**So that** I can quickly join the platform without creating another password to remember.

## Acceptance Criteria

- [ ] Given a new user visits the signup page, when they click "Sign up with GitHub" and complete OAuth flow, then they are redirected to profile creation with their email pre-populated
- [ ] Given a new user visits the signup page, when they click "Sign up with Google" and complete OAuth flow, then they are redirected to profile creation with their email pre-populated
- [ ] Given a user has already signed up with GitHub, when they attempt to sign up again with the same GitHub account, then they receive an error message indicating an account already exists
- [ ] Given OAuth callback receives an email that's already registered with a different provider, when the user attempts to link it, then they receive an error to sign in using the original provider

## Notes

OAuth providers must follow security best practices with PKCE flow. Email from OAuth provider becomes the primary identifier for account linking.