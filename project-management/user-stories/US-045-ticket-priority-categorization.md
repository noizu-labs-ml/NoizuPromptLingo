---
id: US-045
title: "Ticket Priority and Categorization"
slug: "ticket-priority-categorization"
personas: [P-007, P-002, P-001]
epic: "Support & Communication"
priority: "must-have"
complexity: "S"
tags: [support, tickets, priority, categorization]
---

# US-045: Ticket Priority and Categorization

## User Story

**As a** client submitting a support request (P-007),
**I want to** assign a priority level and category to my support ticket when I create it,
**So that** Keith can triage incoming requests correctly and I can find tickets later by type.

## Acceptance Criteria

- [ ] Given I am creating a ticket (US-039), when I fill out the form, then I must select a category from a predefined list (bug/issue, question, change request, billing, general)
- [ ] Given I am creating a ticket, when I fill out the form, then I can optionally select a priority (low, medium, high, urgent) with "medium" as default
- [ ] Given I select "urgent" priority, when I hover or tap an info icon, then I see a description of what constitutes an urgent issue (e.g. production system down, blocking critical path)
- [ ] Given Keith receives a ticket, when he views the admin queue, then tickets are sorted with urgent first, then by creation date
- [ ] Given I submit a ticket with "urgent" priority, when it is created, then a warning is shown that urgent tickets have an SLA expectation of 4-hour response during business hours

## Notes

Priority descriptions should set clear expectations to avoid all tickets being submitted as "urgent." Category and priority are client-set at creation; Keith can override in admin. Consider auto-suggested category based on keywords in the subject (future ML feature). SLA targets per priority: urgent=4h, high=1 business day, medium=2 business days, low=best effort.
