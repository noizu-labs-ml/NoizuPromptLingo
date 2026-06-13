---
id: US-007
title: "Telemetry Baseline Learning Period"
slug: "baseline-learning-period"
personas: [P-001, P-006]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "L"
tags: [onboarding, ml, baseline, anomaly-detection, telemetry]
---

# US-007: Telemetry Baseline Learning Period

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** IoTGo to observe my fleet's telemetry for a configurable learning period before activating anomaly detection,
**So that** agents have accurate normal-behavior baselines and generate fewer false-positive alerts.

## Acceptance Criteria

- [ ] Given a connected source with active devices, when I initiate the baseline learning period, then I can configure the duration (default 7 days, min 1 day, max 30 days) and which device groups to include.
- [ ] Given the learning period is active, when I view its status, then I see a progress indicator showing elapsed time, number of devices being profiled, and estimated completion time.
- [ ] Given the learning period completes, when I view a device's baseline profile, then I see per-metric statistical summaries (mean, stddev, min/max, percentile bands) segmented by time-of-day and day-of-week if sufficient data exists.
- [ ] Given the learning period completes, when agents are created against this fleet, then they default to using the computed baselines for anomaly thresholds rather than generic static thresholds.
- [ ] Given insufficient data for a device (fewer than 100 telemetry messages), when the learning period ends, then that device is flagged as "insufficient baseline" and excluded from autonomous anomaly detection until more data accumulates.

## Notes

Data Scientist persona (P-006) will want to inspect and override learned baselines — that tuning capability is addressed in the Agent Management epic. Learning period can run in parallel with manual agent setup.
