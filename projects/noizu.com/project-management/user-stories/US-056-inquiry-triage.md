---
id: US-056
title: "Inquiry Triage"
slug: "inquiry-triage"
personas: [P-007]
epic: "Admin Dashboard"
priority: "must-have"
complexity: "M"
tags: [admin, inquiry, triage, contact, response]
---

# US-056: Inquiry Triage

## User Story

**As a** site administrator,
**I want to** review, categorize, and respond to incoming contact form inquiries from a dedicated triage queue,
**So that** I can prioritize leads, respond efficiently, and track which inquiries have been addressed.

## Acceptance Criteria

- [ ] Given a new inquiry arrives via the contact form, when it is submitted, then it appears in the admin triage queue with status "New" and triggers a notification.
- [ ] Given I am viewing the triage queue, when I open an inquiry, then I see the full submission: name, email, company, message, service interest, timestamp, and any attached metadata (referrer URL, UTM params).
- [ ] Given I am viewing an inquiry, when I assign a category (Lead, Support, Spam, Partnership, Press), then the categorization is saved and the inquiry moves to the appropriate filtered view.
- [ ] Given I am viewing an inquiry, when I click "Reply", then a compose window pre-fills with the sender's email and I can send a response that is logged against the inquiry record.
- [ ] Given I mark an inquiry as "Resolved", when confirmed, then it moves to the closed queue and is excluded from the open count on the admin dashboard.
- [ ] Given the triage queue, when I filter by status or category, then the list updates without a full page reload.

## Notes

Triage feeds into RFI workflow (US-066 onward) when a lead warrants a formal proposal. Email responses should be sent via the configured transactional email provider. Related: US-051, US-066.
