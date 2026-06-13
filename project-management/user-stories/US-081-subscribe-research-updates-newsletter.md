---
id: US-081
title: "Subscribe to Research Updates Newsletter"
slug: "subscribe-research-updates-newsletter"
personas: [P-008, P-001, P-003]
epic: "Research & Community"
priority: "should-have"
complexity: "S"
tags: [research, newsletter, email, subscription]
---

# US-081: Subscribe to Research Updates Newsletter

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** subscribe to email updates when new research papers are published,
**So that** I stay informed about Keith's latest work without having to revisit the site manually.

## Acceptance Criteria

- [ ] Given the research section of the site, when a visitor finds the newsletter signup widget, then they can enter their email and submit with a single click
- [ ] Given a valid email submitted, when the form is processed, then a double opt-in confirmation email is sent and a success message displayed
- [ ] Given the confirmation email, when the subscriber clicks the confirm link, then their subscription is activated and they receive a welcome email
- [ ] Given an already-subscribed email submitted, then the form shows "You're already subscribed" without creating a duplicate
- [ ] Given a new paper published, when the newsletter is triggered, then subscribers receive an email with the paper title, abstract, and link to read more
- [ ] Given the subscription widget, then it is present on the research index page and on individual paper pages

## Notes

Integration options: ConvertKit, Mailchimp, or Resend with a simple subscriber table. Double opt-in is required for GDPR compliance. Related to US-084 (notification preferences) for subscribers who are also registered users.
