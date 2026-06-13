---
id: US-034
title: "Approve/Reject a Mockup Version"
slug: "approve-reject-mockup-version"
personas: [P-002, P-004, P-005]
epic: "Stakeholder Feedback"
priority: "should-have"
complexity: "M"
tags: [approval, workflow, versioning, signoff]
---

# US-034: Approve/Reject a Mockup Version

## User Story

**As a** enterprise architect (P-005),
**I want to** formally approve or reject a specific mockup version,
**So that** there is a clear audit trail of design decisions and stakeholder sign-off before development begins.

## Acceptance Criteria

- [ ] Given a mockup version, when I click "Approve", then the version is marked approved with my identity and timestamp
- [ ] Given a mockup version, when I click "Reject" and enter a reason, then the version is marked rejected and the author is notified
- [ ] Given a mockup has required approvers, when all have approved, then the mockup status changes to "Approved" automatically
- [ ] Given an approved version, when it is superseded by a new version, then the previous approval is invalidated and reapproval is required

## Notes

Approval workflows should support configuring required approvers. Approval state should be clearly visible on the mockup header. Audit log should be exportable per US-038.
