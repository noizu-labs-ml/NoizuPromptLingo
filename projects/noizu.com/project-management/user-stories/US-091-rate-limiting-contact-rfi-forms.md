---
id: US-091
title: "Rate Limiting on Contact & RFI Forms"
slug: "rate-limiting-contact-rfi-forms"
personas: [P-001, P-002, P-003]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [security, rate-limiting, forms, spam-prevention, contact, rfi]
---

# US-091: Rate Limiting on Contact & RFI Forms

## User Story

**As a** site operator (Keith),
**I want** the contact and RFI forms to enforce rate limits,
**So that** the inbox is protected from spam floods and abuse, and legitimate users are given clear feedback when they submit too frequently.

## Acceptance Criteria

- [ ] Given a visitor submitting the contact form, when they have submitted more than 3 times from the same IP within a 10-minute window, then subsequent submissions return a rate-limit error message
- [ ] Given a rate-limited form submission, when the error is displayed, then it states approximately how long the user must wait before trying again
- [ ] Given rate limit enforcement, when a legitimate user is affected, then the error message is polite and suggests contacting via email as an alternative
- [ ] Given authenticated users submitting RFI forms, when rate limits are applied, then they are tied to the user account rather than IP address alone
- [ ] Given form submissions, when a honeypot field is filled (bot detection), then the submission is silently discarded with a fake success response
- [ ] Given a bot attempting rapid form submission, when rate limiting triggers, then no notification email is sent to Keith

## Notes

Implementation: server-side rate limiting via Redis sliding window counter keyed by IP + form type. Return HTTP 429 with Retry-After header. Honeypot field: hidden CSS field that legitimate users won't fill. Consider also integrating hCaptcha as a fallback for persistent abuse. Related to US-093 (offline resilience).
