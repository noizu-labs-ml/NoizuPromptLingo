---
id: US-002
title: "Sign Up with GitHub OAuth"
slug: "sign-up-with-github-oauth"
personas: [P-001, P-003, P-008]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "S"
tags: [auth, registration, oauth, github]
---

# US-002: Sign Up with GitHub OAuth

## User Story

**As a** developer or security researcher with an existing GitHub identity (P-001, P-003, P-008),
**I want to** register using my GitHub account,
**So that** I can skip manual credential management and start exploring the platform immediately.

## Acceptance Criteria

- [ ] Given I click "Sign up with GitHub" on the registration page, when I complete GitHub's OAuth consent flow, then my account is created and I am redirected to the onboarding wizard
- [ ] Given I complete the GitHub OAuth flow, when my GitHub email is already linked to an existing account, then I am logged into that account and shown a confirmation banner rather than creating a duplicate
- [ ] Given a successful OAuth sign-up, when my account is created, then my display name is pre-populated from GitHub profile data and I can change it during onboarding
- [ ] Given I deny GitHub OAuth permissions or cancel the flow, when I return to the site, then I land back on the sign-up page with no account created

## Notes

Skips the email verification step (US-003) when the GitHub email is already verified by GitHub. Links to US-007 (onboarding wizard) as the post-registration destination.
