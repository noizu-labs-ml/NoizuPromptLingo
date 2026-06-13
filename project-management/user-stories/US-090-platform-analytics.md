---
id: US-090
title: "Admin: View Platform Analytics"
slug: "platform-analytics"
personas: [P-008]
epic: "Admin & Moderation"
priority: "could-have"
complexity: "L"
tags: [admin, analytics, metrics, growth, revenue, reporting]
---

# US-090: Admin: View Platform Analytics

## User Story

**As a** platform admin (P-008),
**I want to** view detailed platform analytics including user growth, revenue trends, and engagement metrics,
**So that** I can make data-driven decisions about product direction and marketing.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/analytics`, when the page loads, then I see a date range picker (default: last 30 days) and charts for: New Signups, Plan Conversions (Free → Pro, Pro → Team), MRR, Competition Entries, and AI Score Requests.
- [ ] Given I select a custom date range, when I apply it, then all charts update to reflect data for that period within 3 seconds.
- [ ] Given the signups chart, when I hover over a data point, then a tooltip shows the exact count for that day and the % change from the same day in the prior period.
- [ ] Given the plan conversion section, when displayed, then I see a funnel visualization showing: Total Registrations → Email Verified → Blog Submitted → Pro Upgrade, with conversion rates at each step.
- [ ] Given the revenue section, when displayed, then I see MRR broken down by plan (Pro vs Team), churn rate, and net revenue growth % month-over-month.
- [ ] Given any chart, when I click "Export CSV," then a CSV file is downloaded containing the underlying data for the currently selected date range.
- [ ] Given analytics data, when displayed, then all charts meet WCAG AA contrast standards and include text-based data tables as an accessible alternative.

## Notes

Analytics should be computed from event logs or a dedicated analytics table, not from live queries on primary tables. Consider integrating with PostHog (already in the infra stack) for behavioral analytics. Revenue data sourced from Stripe API. Relates to US-083.
