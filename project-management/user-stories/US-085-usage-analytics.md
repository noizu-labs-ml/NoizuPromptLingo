---
id: US-085
title: "Platform Usage Analytics"
slug: "usage-analytics"
personas: [P-006]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "L"
tags: [admin, analytics, reporting, metrics, growth]
---

# US-085: Platform Usage Analytics

## User Story

**As a** platform administrator (P-006),
**I want to** view detailed analytics on user growth, feature adoption, generation volume, and retention,
**So that** I can make data-driven decisions about product priorities and infrastructure scaling.

## Acceptance Criteria

- [ ] Given I am on /admin/analytics, when I select a date range, then I see line charts for: new signups, DAU/WAU/MAU, generation requests, and consistency checks run.
- [ ] Given I view the feature adoption panel, when I look at the data, then I see the percentage of active users who have used each major feature (graph, generation studio, export, etc.) in the selected period.
- [ ] Given I view the retention cohort table, when I select a cohort month, then I see week-over-week retention percentages for users who signed up in that month.
- [ ] Given I click "Export report," when the download completes, then I receive a CSV with the displayed metrics and the selected date range noted in the filename.
- [ ] Given I am on the analytics page, when the data is loading, then skeleton loaders are shown for each chart panel and actual data replaces them within 3 seconds.

## Notes

Depends on US-083 (admin dashboard). Analytics data should be pre-aggregated via a nightly job to ensure sub-3-second load times. PII must be excluded from all exported analytics reports.
