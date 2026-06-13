---
id: US-092
title: "Session Expiration Handling"
slug: "session-expiration-handling"
personas: [P-007, P-001, P-002, P-003]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [authentication, session, ux, error-handling, security]
---

# US-092: Session Expiration Handling

## User Story

**As an** existing client with an active engagement (P-007),
**I want to** receive a clear warning when my session is about to expire and be redirected gracefully when it does,
**So that** I do not lose unsaved work and I understand why I am suddenly logged out.

## Acceptance Criteria

- [ ] Given an authenticated user with a session approaching expiration (5 minutes remaining), when the threshold is crossed, then a non-intrusive banner or toast warns them with time remaining and a "Stay logged in" button
- [ ] Given the "Stay logged in" action, when clicked, then the session is silently refreshed and the warning is dismissed
- [ ] Given a session that expires while the user is idle, when they next interact with the page, then they are redirected to the login page with a query param `?reason=session_expired`
- [ ] Given the login page with `reason=session_expired`, then an explanatory message is shown: "Your session has expired. Please sign in again."
- [ ] Given a POST/PUT action (e.g., form submit) attempted after session expiry, when the server returns 401, then the in-progress data is preserved in sessionStorage and the user is redirected to login
- [ ] Given login after session expiry with preserved form data, when the user is redirected back, then the preserved data is restored and they can re-submit

## Notes

Session expiry detection via JWT exp claim checked client-side. Server-side 401 interception needed for API calls. Data preservation (AC 5–6) applies primarily to long-form submissions (RFI, project notes). Related to US-094 (form data recovery after crash), US-091 (rate limiting).
