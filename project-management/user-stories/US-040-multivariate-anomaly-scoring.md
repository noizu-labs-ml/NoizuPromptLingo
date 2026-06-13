---
id: US-040
title: "Multivariate Anomaly Scoring"
slug: "multivariate-anomaly-scoring"
personas: [P-006, P-001, P-004]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "XL"
tags: [anomaly-detection, multivariate, scoring, ml, correlation]
---

# US-040: Multivariate Anomaly Scoring

## User Story

**As a** Data Scientist/ML Engineer (P-006),
**I want to** score anomalies based on the joint distribution of multiple correlated telemetry signals simultaneously,
**So that** I can detect subtle anomalies that only appear when multiple metrics deviate together and would be invisible to per-metric threshold checks.

## Acceptance Criteria

- [ ] Given a device with multiple monitored metrics, when I configure multivariate anomaly detection, then I can select a set of correlated metrics (e.g., temperature + fan speed + power draw) to be evaluated jointly
- [ ] Given multivariate scoring is enabled, when a new telemetry window arrives, then the engine produces a single composite anomaly score (0–100) representing the joint deviation from the learned multivariate baseline
- [ ] Given an anomaly is flagged by multivariate scoring, when I inspect it, then I see the contribution weight of each individual metric to the composite score
- [ ] Given a metric group configuration, when I view the correlation matrix for the group, then I see learned pairwise correlations with confidence levels based on the training data volume
- [ ] Given a high composite anomaly score, when it crosses a configured threshold, then it can trigger playbook conditions defined in US-028 (anomaly score condition type)

## Notes

Multivariate scoring is more computationally intensive than per-metric scoring; the engine should process it asynchronously with a configurable latency target (default: score within 30 seconds of window close). Depends on US-039 for baseline data.
