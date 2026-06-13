---
id: US-091
title: "Creator Tier with Listing Analytics"
slug: "creator-tier-listing-analytics"
personas: [P-002, P-008]
epic: "Monetization & Subscriptions"
priority: "should-have"
complexity: "L"
tags: [monetization, subscription, creator, analytics, site-owners]
---

# US-091: Creator Tier with Listing Analytics

## User Story

**As an** Indie Web Developer (P-002),
**I want to** upgrade to the Creator tier and see analytics for how my listing is performing,
**So that** I can understand how much referral traffic gotta.cc is generating for my site and optimize my listing accordingly.

## Acceptance Criteria

- [ ] Given I am on the Creator tier, when I view my listing's analytics dashboard, then I see a 30-day rolling chart of: listing impressions (views in category/search results), listing clicks (outbound clicks to my site), and click-through rate
- [ ] Given I view my analytics dashboard, when I select a specific date range, then the chart and summary numbers update to reflect that period
- [ ] Given I am on the Creator tier, when I visit the API settings page, then I have access to API key generation with a higher rate limit tier than the Supporter plan
- [ ] Given I am on the free tier and view my listing, when I see the analytics section, then it is blurred/locked with an upgrade prompt for the Creator tier
- [ ] Given Creator tier includes priority re-scoring, when I request a manual rescore of my listing, then the rescore is processed within 4 hours (vs. 7 days for free tier)

## Notes

Analytics data must be aggregated — never expose individual visitor data. The Creator tier is the primary monetization driver for site owners; it should be priced above Supporter (P-001) to reflect the business value. Listing impressions and click-through data connect to US-083 and US-087 (API usage).
