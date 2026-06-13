---
id: US-002
title: "Services Overview Page"
slug: "services-overview-page"
personas: [P-001, P-002, P-003, P-006]
epic: "Public Portfolio"
priority: "must-have"
complexity: "M"
tags: [services, navigation, conversion, detail-page]
---

# US-002: Services Overview Page

## User Story

**As a** VP of Engineering evaluating external fractional support (P-002),
**I want to** browse a structured list of available services with clear scope descriptions,
**So that** I can identify which engagement type maps to my current problem and share it with my procurement team.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/services`, when the page renders, then all eight service categories are present: Fractional CTO, Principal Engineer, QC, Code Audit & Threat Modeling, Service Readiness, Development, Technical PM, IoT & Embedded.
- [ ] Given any service card/section, when a visitor reads it, then a brief description (2–4 sentences), key deliverables, and a CTA to inquire are visible.
- [ ] Given a visitor on mobile (375px), when viewing the services list, then cards stack vertically and remain fully readable without horizontal scroll.
- [ ] Given an enterprise procurement manager (P-006), when viewing the page, then enough detail exists to initiate a vendor evaluation without a phone call.
- [ ] Given the inquiry CTA on a service is clicked, when the contact form opens (US-011), then the selected service is pre-filled in the inquiry type field.

## Notes

Each service may eventually have its own detail page (could-have). For now a single page with anchored sections suffices. Related: US-001 (hero CTA), US-011 (contact form pre-fill), US-013 (RFI submission).
