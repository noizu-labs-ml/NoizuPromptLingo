---
id: US-027
title: "View Submission Status"
slug: "view-submission-status"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "must-have"
complexity: "S"
tags: [submission, status, transparency]
---

# US-027: View Submission Status

## User Story

**As an** indie web developer (P-002),
**I want to** check the current status of my submitted URL,
**So that** I know whether it is pending review, approved, or rejected without having to wait for an email.

## Acceptance Criteria

- [ ] Given I have submitted a URL, when I visit my submission history, then I see each submission with a status badge: Pending, In Review, Approved, or Rejected
- [ ] Given my submission status changes, when I next log in, then the updated status is visually highlighted so I notice it immediately
- [ ] Given a submission is Approved, when I view its status entry, then I see a direct link to the live directory listing

## Notes

Status tracking feeds into the submission history dashboard (US-032). Rejection status leads directly to the rejection feedback flow (US-028).
