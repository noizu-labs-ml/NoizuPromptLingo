---
id: US-003
title: "Update a session's status/title/description as work evolves"
slug: "update-session-status-title-description"
personas: [P-001]
epic: "Work Sessions"
priority: "should-have"
complexity: "S"
tags: [sessions, lifecycle, metadata]
---

# US-003: Update a session's status/title/description as work evolves

## User Story

**As a** Harness Operator (P-001),
**I want to** update a session's status, title, or description after it was created,
**So that** the session record stays an accurate, human-readable log of what the work actually turned into, not just what it was originally scoped as.

## Acceptance Criteria

- [ ] Given an existing session in "active" status, when the operator calls Session.Update with a new title and description, then the session's title/description are persisted and its status is unchanged.
- [ ] Given an existing session, when the operator sets its status to "completed", then subsequent status-filtered session list calls for "active" no longer return that session.
- [ ] Given a Session.Update call with an invalid status value not in the supported enum, when submitted, then the call is rejected with a validation error and the session's prior status is retained.
- [ ] Given a session the operator does not have access to (different org), when they attempt Session.Update, then the call is rejected with an authorization error and no fields change.

## Notes

Session status values gate visibility in list/filter views such as US-004.
