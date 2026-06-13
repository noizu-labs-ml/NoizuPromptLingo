---
id: US-009
title: "Session Management"
slug: "session-management"
personas: [P-001, P-007]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [auth, session, security, devices]
---

# US-009: Session Management

## User Story

**As an** Enterprise AI Lead (P-007),
**I want to** view and revoke active sessions across my devices,
**So that** I can ensure my account is not being accessed from unauthorized locations.

## Acceptance Criteria

- [ ] Given I am in Account Settings > Security, when I navigate to the "Active Sessions" panel, then I see a list of all active sessions showing device type, browser, approximate location (city/country), and last active timestamp.
- [ ] Given I am viewing my active sessions, when I click "Revoke" on a specific session, then that session token is immediately invalidated and the device is logged out.
- [ ] Given I am viewing my active sessions, when I click "Revoke all other sessions", then all sessions except the current one are invalidated and a confirmation message is shown.
- [ ] Given a session has been inactive for 30 days, when the session cleanup job runs, then the session is automatically expired and the next request with that token returns a 401.
- [ ] Given I log in on a new device, when the login succeeds, then I receive an email notification stating a new session was started, with device info and a link to revoke it if unrecognized.

## Notes

The new-device email notification (AC-5) is particularly important for P-007 in enterprise contexts. Session tokens should be stored as opaque, rotating refresh tokens — not JWTs — to enable server-side revocation. The 30-day idle expiry is configurable.
