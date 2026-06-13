---
id: US-002
title: "OAuth Login via Google and GitHub"
slug: "oauth-login"
personas: [P-001, P-002, P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, google, github, onboarding]
---

# US-002: OAuth Login via Google and GitHub

## User Story

**As a** blogger (P-001),
**I want to** register and log in using my Google or GitHub account,
**So that** I can skip password management and get started faster.

## Acceptance Criteria

- [ ] Given I am on the login or registration page, when I click "Continue with Google", then I am redirected to Google's OAuth consent screen and upon approval my account is created or linked
- [ ] Given I am on the login or registration page, when I click "Continue with GitHub", then I am redirected to GitHub's OAuth consent screen and upon approval my account is created or linked
- [ ] Given an OAuth provider returns a verified email that already exists in the system, when the flow completes, then I am logged into the existing account (no duplicate created)
- [ ] Given an OAuth flow is completed successfully for a new user, when I am redirected back, then I land on the onboarding wizard (US-005) rather than an empty dashboard
- [ ] Given an OAuth provider returns an error or the user cancels, when I am redirected back, then I see a dismissible error banner and remain on the login page

## Notes

OAuth accounts do not require email verification (provider has already verified). Password reset (US-007) is not applicable to OAuth-only accounts — users should be shown a prompt to manage their password via the original provider. Related: US-001, US-003.
