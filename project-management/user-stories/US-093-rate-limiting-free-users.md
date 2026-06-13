---
id: US-093
title: "Rate Limiting for Free Users"
slug: "rate-limiting-free-users"
personas: [P-001, P-004]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [edge-case, rate-limiting, free-tier, quotas, upgrade-prompt]
---

# US-093: Rate Limiting for Free Users

## User Story

**As a** platform operator (P-008),
**I want to** enforce usage quotas on Free-tier users and surface clear upgrade prompts when limits are hit,
**So that** the platform remains financially sustainable while giving free users a fair taste of the product.

## Acceptance Criteria

- [ ] Given I am a Free-tier user and have used my monthly blog submission quota (1 blog), when I attempt to submit a second blog, then I see a modal: "You've reached the Free plan limit of 1 blog submission per month. Upgrade to Pro for unlimited submissions."
- [ ] Given I am a Free-tier user and have used my monthly competition entry quota (3 entries), when I attempt to enter a 4th competition, then the entry button is disabled with tooltip "Monthly entry limit reached — upgrade to Pro."
- [ ] Given I am a Free-tier user requesting AI score analysis, when I have exceeded the monthly AI score request limit (e.g., 5 requests/month), then the "Re-score" button shows a lock icon and clicking it opens the upgrade modal.
- [ ] Given any rate limit is enforced, when the limit is hit, then the upgrade modal includes a clear summary of what the user gains by upgrading (unlimited submissions, entries, AI scores) with a prominent "Upgrade to Pro — $12/mo" CTA.
- [ ] Given I am approaching a limit (80% consumed), when I view my dashboard, then a subtle warning banner appears: "You've used 4 of 5 AI score requests this month. Upgrade to Pro for unlimited access."
- [ ] Given rate limits reset on the first of each month, when the reset occurs, then all quota counters are cleared and any limit-related UI warnings are removed.
- [ ] Given a Free user attempts to access an API endpoint beyond their quota, when the request is made, then the server returns HTTP 429 with a JSON body including `error`, `limit`, `reset_at` fields.

## Notes

Rate limits must be enforced server-side; client-side UI is for UX only. Quota counters stored in Redis with monthly TTL keys (e.g., `quota:user:{id}:blog_submissions:2026-05`). Relates to US-076 (view plan), US-077 (upgrade to Pro), US-100 (API — applies rate limits to API calls too).
