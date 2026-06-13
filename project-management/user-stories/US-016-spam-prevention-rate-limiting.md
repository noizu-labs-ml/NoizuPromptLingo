---
id: US-016
title: "Spam Prevention & Rate Limiting on Forms"
slug: "spam-prevention-rate-limiting"
personas: [P-001, P-002, P-003]
epic: "Contact & Inquiry"
priority: "should-have"
complexity: "M"
tags: [spam, rate-limiting, security, honeypot, captcha]
---

# US-016: Spam Prevention & Rate Limiting on Forms

## User Story

**As the** site owner (Keith),
**I want** the contact and RFI forms to be protected against automated spam and abuse,
**So that** my inbox and database are not flooded with bot submissions and legitimate inquiries are not buried.

## Acceptance Criteria

- [ ] Given a form submission endpoint, when more than 5 requests originate from the same IP within a 10-minute window, then subsequent requests return HTTP 429 and are not processed.
- [ ] Given the contact form HTML, when inspected, then a hidden honeypot field is present that bots are likely to fill but real users will not see.
- [ ] Given a submission where the honeypot field is populated, when the server processes the request, then the submission is silently rejected (returns 200 to avoid signaling detection) and is not stored or emailed.
- [ ] Given a legitimate user submits the form quickly (e.g., copy-pastes and submits), when the rate limit is not exceeded, then their submission is accepted normally.
- [ ] Given rate limiting rejects a request, when the HTTP 429 is returned, then the client-side form shows a user-friendly message asking the user to wait before retrying.

## Notes

Avoid CAPTCHA friction if honeypot + rate limiting proves sufficient — CAPTCHA degrades conversion for legitimate users (P-001, P-002 in particular will bounce). Monitor abuse patterns before escalating to CAPTCHA. Cloudflare Turnstile is a low-friction CAPTCHA alternative if needed. Related: US-011, US-012, US-014.
