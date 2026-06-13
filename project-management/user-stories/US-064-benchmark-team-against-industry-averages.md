---
id: US-064
title: "Benchmark Team Against Industry Averages"
slug: "benchmark-team-against-industry-averages"
personas: [P-002, P-005]
epic: "Academy — Labs"
priority: "could-have"
complexity: "L"
tags: [academy, teams, benchmarking, industry, reporting]
---

# US-064: Benchmark Team Against Industry Averages

## User Story

**As a** CISO at a mid-market SaaS company (P-005),
**I want to** benchmark my team's Academy performance against industry averages and peer organizations,
**So that** I can make the case for continued security training investment and identify where we lag behind comparable teams.

## Acceptance Criteria

- [ ] Given I am a team owner or admin with at least 5 team members who have completed labs, when I view the Benchmarks tab on the team dashboard, then I see my team's aggregate scores compared to anonymized industry averages (overall and by industry vertical if selected)
- [ ] Given benchmarks are displayed, when I view the category breakdown, then I see performance percentile rankings for each lab type (attack, defense, incident response) and each difficulty tier
- [ ] Given I have set my team's industry vertical (e.g., fintech, healthcare, SaaS), when benchmarks load, then I see a secondary comparison against the same-vertical cohort in addition to the overall average
- [ ] Given I want to share benchmark data, when I click "Export Benchmark Report," then I can download a branded PDF showing the benchmark comparison suitable for a board or leadership presentation
- [ ] Given my team's sample is too small for statistically meaningful benchmarks (fewer than 5 active members), when I view the Benchmarks tab, then I see a message explaining the minimum threshold rather than misleading partial data

## Notes

Benchmark data is aggregated anonymously across all teams. Industry vertical must be user-declared and unverified at launch — integrity depends on honest self-categorization. Benchmark reports are a strong enterprise upsell driver and should be gated to paid plans.
