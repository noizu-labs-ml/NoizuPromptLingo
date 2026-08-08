---
id: US-040
title: "Complete a First-Time SSO Callback Flow"
slug: "complete-first-time-sso-callback"
personas: [P-008]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [oidc, sso, callback, newcomer]
---

# US-040: Complete a First-Time SSO Callback Flow

## User Story

**As an** Evaluating Newcomer (P-008) logging in for the first time,
**I want to** have the OIDC callback complete automatically once I've authenticated with Authentik,
**So that** I land inside the app already signed in, without extra manual steps I might not understand.

## Acceptance Criteria

- [ ] Given I have successfully authenticated with Authentik, when Authentik redirects back to the app's callback URL with a valid SSO code, then the backend exchanges the code and issues me a Guardian JWT access/refresh pair without further input from me.
- [ ] Given the SSO code exchange succeeds for a first-time user, when the callback completes, then I am redirected into the app already signed in, with no separate "create password" or "verify email" step shown.
- [ ] Given the SSO code exchange fails (e.g., an invalid or expired code), when the callback runs, then I see a plain-language retry message and am returned to the login start point rather than a raw error page.

## Notes

Immediately follows invite acceptance in US-039. The issued JWT pair is later refreshed per US-044.
