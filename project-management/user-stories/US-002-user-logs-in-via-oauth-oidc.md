---
id: US-002
title: "User logs in via OAuth/OIDC provider"
slug: "user-logs-in-via-oauth-oidc"
personas: [P-001, P-002, P-007]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, oauth, oidc, login]
---

# US-002: User Logs In via OAuth/OIDC Provider

## User Story

**As a** Platform Engineer (P-002) or MCP Tool Developer (P-001),
**I want to** log in to MCP Host using my organization's OAuth 2.0 / OIDC identity provider,
**So that** I can authenticate with my existing corporate credentials without managing a separate password.

## Acceptance Criteria

- [ ] Given the MCP Host login page, when the user clicks "Log in with GitHub" or "Log in with Google," then the system redirects to the provider's consent screen, processes the OAuth callback, and establishes an authenticated session.
- [ ] Given a successful OIDC authentication, when the ID token contains verified email and name claims, then the system creates or updates the local user profile with those claims and issues a platform session token.
- [ ] Given an expired session token, when the user makes an authenticated request, then the system attempts a silent token refresh via the refresh token; if refresh fails, the user is redirected to re-authenticate.
- [ ] Given a user who previously authenticated with a social provider, when they attempt to log in with a different provider using the same email address, then the system links the identity to the existing account and logs the user in.
- [ ] Given the MCP Host login page, when the user enters email and password (non-OAuth login), then the system validates credentials against the local store and issues a session token on success.

## Notes

Supports GitHub, Google, and Microsoft as initial OAuth/OIDC providers. The session token is a JWT used for API authentication. This story covers the human login flow; machine caller authentication is US-006. Related to US-001 (sign-up), US-011 (SSO/SAML), and US-006 (API key auth).
