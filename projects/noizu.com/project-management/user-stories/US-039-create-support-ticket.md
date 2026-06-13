---
id: US-039
title: "Create Support Ticket"
slug: "create-support-ticket"
personas: [P-007, P-001, P-002, P-003]
epic: "Support & Communication"
priority: "must-have"
complexity: "M"
tags: [support, tickets, communication, authenticated]
---

# US-039: Create Support Ticket

## User Story

**As an** active client with a question or issue (P-007),
**I want to** create a support ticket from within the dashboard,
**So that** I have a tracked, structured channel for raising issues, questions, or change requests without relying on informal emails.

## Acceptance Criteria

- [ ] Given I am authenticated, when I click "New Ticket", then I see a form with fields for: subject, description, priority (low/medium/high/urgent), category, and optional project association
- [ ] Given I submit a valid ticket form, when it is created, then I receive an in-app confirmation and an email acknowledgment with the ticket ID
- [ ] Given I associate a ticket with a project, when Keith views the ticket, then the project context is visible alongside the ticket
- [ ] Given I submit a ticket with "urgent" priority, when it is created, then Keith receives an immediate notification (beyond standard digest)
- [ ] Given I attempt to submit a ticket with an empty subject or description, when I click submit, then inline validation errors are shown and the form is not submitted

## Notes

Ticket subject max 140 chars; description max 2000 chars with markdown support. Categories: bug/issue, question, change request, billing, general. Priority escalation for urgent tickets should trigger a distinct notification path (see US-048). All tickets linked to a client account. Unauthenticated support requests go through the public contact form (existing), not this flow.
