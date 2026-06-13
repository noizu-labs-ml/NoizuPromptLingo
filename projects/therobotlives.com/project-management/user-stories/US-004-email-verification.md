---
id: US-004
title: "Email Verification"
slug: "email-verification"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Authentication & Signup"
priority: "should-have"
complexity: "M"
tags: [authentication, email, verification]
---

# US-004: Email Verification

## User Story

**As a** MCP Server Developer (P-005),
**I want to** verify my email address before accessing certain features,
**So that** the platform can prevent spam and ensure reliable communication.

## Acceptance Criteria

- [ ] Given a new user completes OAuth signup, when they receive a verification email with a unique token, then clicking the link marks their email as verified
- [ ] Given an unverified user, when they attempt to create a space or post content, then they receive a prompt to verify their email first
- [ ] Given a verification link is clicked, when the token is expired (older than 24 hours), then the user is prompted to request a new verification email
- [ ] Given a user requests a new verification email, when they click the new link, then the previous token is invalidated
- [ ] Given an email is marked as verified, when the user changes their email address, then the new email must go through verification again

## Notes

Verification is required for write operations. Read-only access (browsing spaces, reading threads) works without verification.