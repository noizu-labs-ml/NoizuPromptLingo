---
id: US-008
title: "Session Management and Logout"
slug: "session-management"
personas: [P-001, P-002, P-003]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [auth, session, security, logout]
---

# US-008: Session Management and Logout

## User Story

**As a** logged-in user (P-002),
**I want to** view and manage my active sessions across devices and log out,
**So that** I can maintain security over my account if a device is lost or compromised.

## Acceptance Criteria

- [ ] Given I am logged in, when I navigate to Settings > Security, then I see a list of active sessions showing: device type, browser, approximate location, last active time, and whether it is the current session
- [ ] Given I view my active sessions, when I click "Revoke" on any non-current session, then that session token is invalidated and the user is logged out on that device within 5 minutes
- [ ] Given I click "Log out all other devices", when I confirm the action, then all sessions except the current one are invalidated immediately
- [ ] Given I click "Log out" from any page, when I confirm, then my current session token is invalidated, cookies are cleared, and I am redirected to the login page
- [ ] Given my session has been idle for 30 days, when I make a request, then I am redirected to the login page with a message "Your session has expired. Please log in again."

## Notes

Sessions should store: token hash (not plaintext), user agent, IP address, created_at, last_used_at. Consider showing a warning banner when a new login is detected from an unfamiliar location. Related: US-007 (password reset invalidates all sessions), US-004 (login creates a session).
