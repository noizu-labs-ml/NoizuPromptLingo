---
id: US-014
title: "Inquiry Public Status Tracking"
slug: "inquiry-public-status-tracking"
personas: [P-002, P-006]
epic: "Contact & Inquiry"
priority: "could-have"
complexity: "M"
tags: [inquiry, status, tracking, reference-number, transparency]
---

# US-014: Inquiry Public Status Tracking

## User Story

**As an** enterprise procurement manager who submitted an RFI (P-006),
**I want to** check the status of my inquiry using my reference number without logging in,
**So that** I can confirm receipt, know when to expect a response, and share status with my team.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/inquiry/status`, when the page loads, then a form with a single "Reference Number" input and submit button is rendered.
- [ ] Given a valid reference number is entered and submitted, when the lookup resolves, then the inquiry summary (service type, submission date, current status) is displayed — no PII beyond the submitter's own data.
- [ ] Given an invalid or unknown reference number is submitted, when the lookup resolves, then a neutral message is shown ("No inquiry found with that reference number") without indicating whether the number format is valid.
- [ ] Given an inquiry's status is updated by Keith (admin side), when the submitter looks up their reference number, then the updated status is reflected within 60 seconds.
- [ ] Given the status page is accessed, when rendered, then no authentication is required (public, reference-number-gated).

## Notes

Statuses: Received, Under Review, Response Sent, Closed. This is intentionally lightweight — full inquiry management is in the client dashboard (future stories). Related: US-012 (RFI reference number), US-016 (spam/abuse prevention applies here too).
