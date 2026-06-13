---
id: US-015
title: "Inquiry Confirmation Email"
slug: "inquiry-confirmation-email"
personas: [P-001, P-002, P-003]
epic: "Contact & Inquiry"
priority: "must-have"
complexity: "S"
tags: [email, confirmation, transactional, inquiry]
---

# US-015: Inquiry Confirmation Email

## User Story

**As a** founder who just submitted a contact form (P-003),
**I want to** receive an immediate confirmation email acknowledging my inquiry,
**So that** I know the message was received and I have a record of what I sent.

## Acceptance Criteria

- [ ] Given a contact form (US-011) or RFI (US-012) is successfully submitted, when the server processes the submission, then a confirmation email is sent to the provided address within 60 seconds.
- [ ] Given the confirmation email is sent, when the recipient opens it, then it contains: a thank-you message, a summary of submitted fields, the reference number (for RFIs), and an expected response timeframe.
- [ ] Given the email is received, when the subject line is read, then it clearly identifies the sender and inquiry type (e.g., "Your inquiry to noizu.com — Fractional CTO").
- [ ] Given the email is opened on mobile, when rendered, then the layout is responsive and readable on 375px screens.
- [ ] Given an invalid or undeliverable email address is provided, when the delivery fails, when the error is logged, then the failure does not surface as a 500 error to the submitter.

## Notes

Use a transactional email provider (Resend, Postmark, or SendGrid). HTML email template should match the site's visual design. Plain-text fallback required. Reply-to should be set to Keith's email so replies route correctly. Related: US-011, US-012, US-016.
