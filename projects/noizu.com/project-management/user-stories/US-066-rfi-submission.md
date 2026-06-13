---
id: US-066
title: "RFI Submission Form"
slug: "rfi-submission"
personas: [P-001, P-002, P-003, P-004]
epic: "RFI Dashboard"
priority: "must-have"
complexity: "L"
tags: [rfi, prospect, form, lead, submission]
---

# US-066: RFI Submission Form

## User Story

**As a** startup CTO evaluating consulting options (P-001),
**I want to** submit a structured Request for Information specifying my service needs, budget range, timeline, and technical context,
**So that** I can receive a tailored response without a back-and-forth discovery cycle.

## Acceptance Criteria

- [ ] Given I navigate to `/rfi` or click "Request Information" on any service page, when the page loads, then I see a multi-step form with sections: Contact Info, Service Type, Technical Context, Budget & Timeline, Additional Notes.
- [ ] Given the "Service Type" step, when I select a service (e.g., Fractional CTO), then contextually relevant follow-up fields appear (e.g., team size, current tech stack, growth phase).
- [ ] Given the "Budget & Timeline" step, when I select a budget range (< $5k/mo, $5–10k/mo, $10–20k/mo, $20k+/mo) and a timeline (ASAP, 1–3 months, 3–6 months, 6+ months), then my selections are captured.
- [ ] Given I complete all required fields and submit, when submission succeeds, then I receive a confirmation page with a unique RFI reference number and an email confirmation.
- [ ] Given I am submitting the RFI, when my session is interrupted mid-form, then my progress is saved in localStorage and restored when I return to the page.
- [ ] Given the form submission, when the server receives it, then the RFI record is created with status "Submitted" and the admin receives a notification (US-056, US-060).

## Notes

Multi-step form reduces abandonment vs. a single long form. Contextual fields per service type require a field configuration map. RFI reference number format: RFI-YYYY-NNNN. Related: US-056, US-067, US-068.
