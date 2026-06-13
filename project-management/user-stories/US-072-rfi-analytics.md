---
id: US-072
title: "RFI Analytics"
slug: "rfi-analytics"
personas: [P-007]
epic: "RFI Dashboard"
priority: "could-have"
complexity: "M"
tags: [admin, rfi, analytics, conversion, reporting]
---

# US-072: RFI Analytics

## User Story

**As a** site administrator,
**I want to** view RFI funnel analytics showing submission volume, conversion rates by service type, average response time, and win/loss breakdown,
**So that** I can understand which services attract the most qualified leads and where prospects drop out of the funnel.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/rfi/analytics`, when the page loads, then I see a summary for the selected period: total RFIs submitted, responded, converted to proposal, accepted, and declined.
- [ ] Given the analytics page, when I select a date range, then all metrics update to reflect that period.
- [ ] Given the funnel visualization, when I view it, then I see a stage-by-stage funnel: Submitted → Reviewed → Responded → Proposal Issued → Won/Lost with counts and drop-off percentages at each stage.
- [ ] Given the "By Service Type" breakdown, when I view it, then I see submission counts and win rates per service type (Fractional CTO, Code Audit, etc.).
- [ ] Given the "Average Response Time" metric, when displayed, then it shows the median time from submission to first admin response, with a 30-day trend.
- [ ] Given I export analytics data, when the export runs, then a CSV is generated with per-RFI rows including all funnel stage timestamps.

## Notes

This is reporting-only — no ML or predictive features at this stage. Win = proposal accepted + engagement started. Loss = proposal declined or RFI closed without proposal. Related: US-064 (site analytics), US-068, US-069.
