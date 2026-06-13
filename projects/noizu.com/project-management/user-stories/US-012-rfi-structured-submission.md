---
id: US-012
title: "RFI — Structured Request for Information Submission"
slug: "rfi-structured-submission"
personas: [P-002, P-006]
epic: "Contact & Inquiry"
priority: "should-have"
complexity: "L"
tags: [rfi, inquiry, structured-form, enterprise, scoping]
---

# US-012: RFI — Structured Request for Information Submission

## User Story

**As an** enterprise procurement manager running a vendor evaluation (P-006),
**I want to** submit a structured Request for Information with budget range, timeline, and detailed scope,
**So that** I receive a tailored response that matches our evaluation criteria without a back-and-forth discovery cycle.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/contact/rfi` or reaches it from a service page CTA, when the form loads, then structured fields are present: Company, Role, Project Description, Service Type(s) (multi-select), Estimated Timeline, Budget Range (range select), Team Size, and Additional Notes.
- [ ] Given a visitor completes the RFI form and submits, when the submission is received, then a unique reference number (e.g., RFI-2024-0042) is generated and shown to the visitor.
- [ ] Given the RFI is submitted, when Keith views the admin dashboard (future: US-030+), then the RFI appears as a structured record with all fields captured.
- [ ] Given a visitor abandons the RFI form after filling 3+ fields, when they return to the page within the same session, then their partial data is preserved (session storage).
- [ ] Given the RFI is submitted, when the confirmation email is sent (US-015), then the reference number and a summary of submitted fields are included.

## Notes

Budget range options: Under $10k, $10k–$50k, $50k–$150k, $150k+, Undetermined. This is a longer form than the basic contact form (US-011) — consider multi-step/wizard UX to reduce abandonment. Related: US-011 (basic contact), US-013 (inquiry categorization), US-015 (confirmation).
