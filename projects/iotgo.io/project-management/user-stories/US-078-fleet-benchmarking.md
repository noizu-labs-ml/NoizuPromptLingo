---
id: US-078
title: "Fleet Benchmarking"
slug: "fleet-benchmarking"
personas: [P-002, P-001]
epic: "Insights & Reporting"
priority: "should-have"
complexity: "M"
tags: [benchmarking, fleet, comparison, reporting]
---

# US-078: Fleet Benchmarking

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** benchmark my fleet's AI agent performance against industry baselines or my own historical periods,
**So that** I can understand whether my fleet is improving and how it compares to similar deployments.

## Acceptance Criteria

- [ ] Given I am on the Benchmarking page, when I select a fleet group, then I see its current-period metrics compared to the previous equivalent period (e.g., last 30d vs prior 30d)
- [ ] Given anonymous benchmark data is available, when I view fleet benchmarking, then an industry-baseline band (anonymized percentile range) is displayed alongside my fleet metrics
- [ ] Given I want to compare two time periods, when I use the period picker to select a custom range, then the comparison chart updates to show both periods side by side
- [ ] Given no prior-period data exists, when I first deploy IoTGo, then the UI displays a message explaining benchmarks will appear after sufficient data is collected

## Notes

Industry baseline data is aggregated anonymously across all IoTGo tenants. Opt-out for benchmark contribution should be available in organization settings. Relates to US-079 (agent performance comparison).
