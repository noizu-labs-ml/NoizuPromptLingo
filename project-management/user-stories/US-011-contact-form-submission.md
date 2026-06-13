---
id: US-011
title: "Contact Form Submission"
slug: "contact-form-submission"
personas: [P-001, P-002, P-003, P-004]
epic: "Contact & Inquiry"
priority: "must-have"
complexity: "M"
tags: [contact, form, inquiry, conversion]
---

# US-011: Contact Form Submission

## User Story

**As a** startup CTO ready to start a conversation (P-001),
**I want to** submit a brief message with my contact details through a form,
**So that** Keith can respond without requiring me to send a cold email or call.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/contact`, when the page loads, then a form with fields for Name, Email, Company (optional), Service Interest (select), Message, and Submit is rendered.
- [ ] Given a visitor submits the form with valid data, when the submission is processed, then a success state is shown inline (no full page reload) and the visitor sees a confirmation message.
- [ ] Given a visitor submits the form with an empty required field, when validation runs, then the specific field is highlighted with an accessible error message before the network request is made.
- [ ] Given a visitor submits an invalid email format, when validation runs, then an error is shown inline on the email field.
- [ ] Given a successful submission, when Keith's admin email is notified, then he receives an email containing all submitted fields within 60 seconds.
- [ ] Given a successful submission, when the confirmation is shown, then the visitor is also informed they will receive a confirmation email (related: US-015).

## Notes

Form submission should POST to a server action or API route. Consider rate limiting per IP to prevent abuse (related: US-016). Service Interest select options should mirror the eight service categories from US-002. Related: US-012 (RFI), US-015 (confirmation email), US-016 (spam prevention).
