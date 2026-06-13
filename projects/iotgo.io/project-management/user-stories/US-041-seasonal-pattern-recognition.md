---
id: US-041
title: "Seasonal Pattern Recognition"
slug: "seasonal-pattern-recognition"
personas: [P-006, P-003, P-002]
epic: "Anomaly Detection"
priority: "should-have"
complexity: "L"
tags: [anomaly-detection, seasonality, patterns, time-series, baseline]
---

# US-041: Seasonal Pattern Recognition

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** configure the anomaly engine to model and account for repeating time-based patterns in telemetry (hourly, daily, weekly cycles),
**So that** predictable periodic behavior is not flagged as anomalous and anomaly scoring remains accurate across different operational contexts.

## Acceptance Criteria

- [ ] Given I enable seasonal modeling for a device metric, when the baseline learning period includes at least two full cycles of the configured seasonality (e.g., two weeks for weekly), then the engine learns time-indexed normal ranges
- [ ] Given seasonal modeling is active, when the engine scores an anomaly at 3 AM on a Monday, then it compares the reading to the learned 3 AM Monday baseline rather than the all-time average
- [ ] Given multiple seasonality periods are configured (e.g., daily + weekly), when they overlap, then the engine applies the most granular matching seasonal window
- [ ] Given a building's HVAC system follows business-hours patterns, when P-003 enables daily seasonality, then weekend low-activity readings do not generate anomaly alerts that would fire on weekdays
- [ ] Given seasonal baselines are established, when I view a metric's baseline chart, then I can toggle between "flat baseline" and "seasonal baseline" views to see how they differ

## Notes

Weekly seasonality requires at least 4 weeks of data to be statistically reliable; the system should surface a data sufficiency warning if fewer cycles are available. Depends on US-039 for the core baseline infrastructure.
