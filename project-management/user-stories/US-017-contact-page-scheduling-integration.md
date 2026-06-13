---
id: US-017
title: "Contact Page — Scheduling Integration"
slug: "contact-page-scheduling-integration"
personas: [P-001, P-002, P-003]
epic: "Contact & Inquiry"
priority: "could-have"
complexity: "S"
tags: [scheduling, cal-com, calendly, contact, conversion]
---

# US-017: Contact Page — Scheduling Integration

## User Story

**As a** VP of Engineering who prefers direct scheduling over waiting for a reply (P-002),
**I want to** book a 30-minute discovery call directly from the contact page,
**So that** I can skip the email back-and-forth and lock in time while I'm motivated.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/contact`, when the page loads, then a scheduling option ("Book a Discovery Call") is visible alongside the contact form.
- [ ] Given the "Book a Discovery Call" link or embed is clicked, when the scheduling UI loads, then available time slots are displayed in the visitor's local timezone.
- [ ] Given a visitor successfully books a slot, when the booking is confirmed, then both Keith and the visitor receive calendar invitations.
- [ ] Given the scheduling embed is loaded, when viewed on mobile (375px), then the embed is fully usable without horizontal scroll.
- [ ] Given the scheduling service is temporarily unavailable, when the embed fails to load, then a fallback message with the contact form CTA is shown.

## Notes

Cal.com (self-hosted) or Calendly are both viable. Cal.com preferred given the existing self-hosted infra posture. Embed vs. redirect link — embed preferred for conversion but introduces third-party script weight. Related: US-011 (contact form as fallback), US-007 (performance impact of scheduling embed).
