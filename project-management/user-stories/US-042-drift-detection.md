---
id: US-042
title: "Drift Detection"
slug: "drift-detection"
personas: [P-006, P-002, P-001]
epic: "Anomaly Detection"
priority: "should-have"
complexity: "M"
tags: [anomaly-detection, drift, degradation, trend, long-term]
---

# US-042: Drift Detection

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** detect gradual metric drift in device telemetry over days or weeks — distinct from acute anomalies,
**So that** slow degradation patterns (e.g., bearing wear, calibration drift, memory leak) are surfaced before they become critical failures.

## Acceptance Criteria

- [ ] Given I enable drift detection for a metric, when I configure it, then I set a drift sensitivity (how many standard deviations of gradual shift over what rolling window triggers a drift alert)
- [ ] Given drift detection is active, when a metric's rolling mean shifts consistently in one direction over the configured window, then a drift event is created with the rate-of-change, direction, and projected time to threshold breach
- [ ] Given a drift event is generated, when I view it, then I see a trend chart overlaying the metric's current trajectory against the learned baseline with a projected breach line
- [ ] Given a drift event, when it is linked to a playbook condition, then it can trigger preventive maintenance playbooks before the metric reaches a critical threshold
- [ ] Given a drift is reversed (metric returns to baseline range), when this occurs, then the drift event is automatically resolved and the resolution is logged

## Notes

Drift detection operates on a much longer time horizon than acute anomaly detection and should use separate configuration. This feeds directly into predictive maintenance use cases for P-002. Depends on US-039 for baseline reference.
