---
id: US-001
title: "User signs up for a new MCP Host account"
slug: "user-signs-up-for-account"
personas: [P-001, P-007]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "S"
tags: [auth, onboarding, registration]
---

# US-001: User Signs Up for a New MCP Host Account

## User Story

**As a** MCP Tool Developer (P-001) or Solo AI Hobbyist (P-007),
**I want to** create a new MCP Host account with my email address or social login,
**So that** I can access the platform to deploy, manage, and secure MCP servers.

## Acceptance Criteria

- [ ] Given the MCP Host sign-up page, when the user submits a valid email and password, then the system creates the account and sends a verification email.
- [ ] Given the MCP Host sign-up page, when the user clicks "Sign up with GitHub" or "Sign up with Google," then the system creates the account using the OAuth provider's identity and redirects to the onboarding wizard.
- [ ] Given a submitted registration, when the email address is already registered, then the system displays a clear error message indicating the account exists and offers a login link.
- [ ] Given a new account created via email/password, when the user clicks the verification link in the email, then the account is marked as verified and the user is redirected to the onboarding wizard.
- [ ] Given an unverified account, when the user attempts to access protected resources, then the system blocks access and prompts the user to verify their email.

## Notes

Registration is the first touchpoint for all three product surfaces (JustMCP.it, MCP Jumpstart, SafeMCP). The account is shared across surfaces. Email verification must complete before any MCP operations are permitted. Related to US-002 (login) and US-012 (first-run experience).
