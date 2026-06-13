---
id: US-013
title: "Inquiry Categorization & Routing"
slug: "inquiry-categorization-routing"
personas: [P-001, P-002, P-006]
epic: "Contact & Inquiry"
priority: "should-have"
complexity: "M"
tags: [inquiry, categorization, routing, admin, triage]
---

# US-013: Inquiry Categorization & Routing

## User Story

**As a** consultant receiving multiple inquiry types (Keith as admin),
**I want** submitted inquiries to be automatically tagged by service type and urgency,
**So that** I can triage and respond to high-priority or high-fit leads first without manually reading every submission.

## Acceptance Criteria

- [ ] Given a contact form (US-011) or RFI (US-012) is submitted, when stored, then the inquiry record includes a `category` field derived from the selected service type.
- [ ] Given an inquiry is submitted with a Budget Range of $50k+, when stored, then the inquiry is flagged as `priority: high` automatically.
- [ ] Given an inquiry is stored, when Keith views his notification email, then the subject line includes the category and priority level (e.g., "[High] Fractional CTO Inquiry — Acme Corp").
- [ ] Given multiple inquiries exist, when Keith accesses the admin dashboard (future story), then inquiries are sortable by category, priority, and submission date.
- [ ] Given an inquiry's category is set, when it is updated by Keith manually, then the new category is persisted and the change is logged with a timestamp.

## Notes

Initial categorization is rule-based (form field → category mapping). AI-assisted triage or scoring is a future enhancement. Related: US-011 (contact form), US-012 (RFI), future admin dashboard stories.
