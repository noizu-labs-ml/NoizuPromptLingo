---
id: US-064
title: "Site Analytics Dashboard"
slug: "site-analytics"
personas: [P-007]
epic: "Admin Dashboard"
priority: "could-have"
complexity: "M"
tags: [admin, analytics, traffic, conversion, seo]
---

# US-064: Site Analytics Dashboard

## User Story

**As a** site administrator,
**I want to** view an embedded analytics summary showing site traffic, top landing pages, contact form conversion rate, and referral sources,
**So that** I can understand how prospective clients discover and engage with the portfolio site.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/analytics`, when the page loads, then I see a 30-day summary of: unique visitors, pageviews, contact form submissions, and form conversion rate.
- [ ] Given the analytics dashboard, when I select a different date range (7d, 30d, 90d, custom), then all metrics update to reflect the selected period.
- [ ] Given the analytics dashboard, when I view the "Top Pages" table, then I see the 10 most-visited pages ranked by pageviews with session counts.
- [ ] Given the analytics dashboard, when I view the "Traffic Sources" breakdown, then I see direct, organic search, referral, and social as categories with percentage shares.
- [ ] Given analytics data is sourced from an external provider (Plausible, PostHog, or similar), when the embed loads, then it displays within the admin UI without requiring a separate tab.

## Notes

Privacy-first analytics preferred (Plausible or PostHog self-hosted). Avoid Google Analytics unless explicitly chosen. Conversion rate = form submissions / unique visitors. Related: US-051, US-072 (RFI analytics).
