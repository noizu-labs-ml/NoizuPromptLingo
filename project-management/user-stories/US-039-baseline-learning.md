---
id: US-039
title: "Anomaly Detection Baseline Learning"
slug: "baseline-learning"
personas: [P-006, P-001, P-002]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "XL"
tags: [anomaly-detection, baseline, ml, telemetry, learning]
---

# US-039: Anomaly Detection Baseline Learning

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** configure the anomaly detection engine to automatically learn a behavioral baseline for each device or device group from historical telemetry,
**So that** anomaly scoring is calibrated to each device's normal operating envelope rather than using static global thresholds.

## Acceptance Criteria

- [ ] Given I enable anomaly detection for a fleet segment, when I configure the baseline learning period (minimum 7 days, recommended 30 days), then the engine ingests historical telemetry and builds per-device statistical profiles for each monitored metric
- [ ] Given baseline learning completes, when I view a device's profile, then I see the learned normal range (mean, stddev, percentile bands) per metric and per time-of-day window
- [ ] Given new telemetry arrives after baseline learning, when the engine scores it, then the score reflects deviation from the learned baseline, not a global threshold
- [ ] Given a device undergoes a known configuration change, when I mark that event in the system, then the engine can optionally restart baseline learning for that device from that point forward
- [ ] Given insufficient historical data exists for a device (< 7 days), when anomaly detection is enabled, then the system notifies me and falls back to fleet-average baseline with a prominent warning label

## Notes

This is the foundational story for the entire anomaly detection epic; most subsequent stories depend on baselines being established. Baseline profiles should be stored per-device and per-metric, not as a single model. Related to US-040 (multivariate scoring) and US-041 (seasonal patterns).
