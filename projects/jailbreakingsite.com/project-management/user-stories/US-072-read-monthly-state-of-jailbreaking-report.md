---
id: US-072
title: "Read Monthly 'State of Jailbreaking' Report"
slug: "read-monthly-state-of-jailbreaking-report"
personas: [P-005, P-002, P-004]
epic: "Community & Disclosure"
priority: "should-have"
complexity: "M"
tags: [community, reports, intelligence, monthly, trends]
---

# US-072: Read Monthly "State of Jailbreaking" Report

## User Story

**As a** CISO at a mid-market SaaS company (P-005),
**I want to** read a monthly "State of Jailbreaking" report that summarizes new techniques, trends, and model-specific findings,
**So that** I stay current on the threat landscape without spending hours reviewing raw catalog updates.

## Acceptance Criteria

- [ ] Given I navigate to Community → Reports, when the page loads, then I see an archive of monthly reports in reverse chronological order, each showing: publication date, edition number, headline summary, and a "Read Report" CTA
- [ ] Given I open a monthly report, when it loads, then it contains at minimum: new techniques added this month (with catalog links), techniques with updated severity ratings, notable community annotations, model provider response summary, and a trend analysis section
- [ ] Given a report references catalog entries, when I click a technique name in the report, then I navigate directly to that catalog entry in a new tab
- [ ] Given I am not a subscriber, when I view a report, then I can read the current month's report in full; reports older than 3 months are paywalled or require registration
- [ ] Given the report is displayed, when I view it on mobile, then the content renders cleanly in a readable long-form article layout

## Notes

Monthly reports are the primary SEO and thought leadership asset for the Community product — they should be authored with the quality of a professional threat intelligence brief, not auto-generated. Reports should be permanently archived and linkable, as they will be cited in external security research.
