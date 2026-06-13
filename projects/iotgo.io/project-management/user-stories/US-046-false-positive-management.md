---
id: US-046
title: "False Positive Management"
slug: "false-positive-management"
personas: [P-006, P-008, P-002]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "M"
tags: [anomaly-detection, false-positive, feedback, model-tuning, noise-reduction]
---

# US-046: False Positive Management

## User Story

**As a** Junior IoT Technician/Field Operator (P-008),
**I want to** mark an anomaly as a false positive and provide a reason,
**So that** the detection model learns from my feedback and generates fewer irrelevant alerts over time.

## Acceptance Criteria

- [ ] Given I view an anomaly event, when I click "Mark as False Positive", then I select a reason category (planned maintenance, known condition, sensor noise, configuration change) and optionally add a free-text note
- [ ] Given an anomaly is marked as a false positive, when the feedback is saved, then the anomaly is dismissed from the active anomaly queue and the feedback is queued for model tuning (US-050)
- [ ] Given multiple users mark similar anomaly patterns as false positives, when the volume exceeds a threshold, then P-006 receives a notification suggesting a model tuning session or custom rule update
- [ ] Given an anomaly was marked as false positive, when I view the anomaly history, then false positive status is preserved and visible alongside the original anomaly data
- [ ] Given I am in a maintenance window for a device group, when I configure the window, then all anomalies generated during the window are automatically pre-labeled as maintenance-context and suppressed from active alerts

## Notes

Maintenance windows as pre-emptive false positive suppression are critical for P-002 and P-008 to avoid alert fatigue during planned operations. Feedback data feeds US-050 (model tuning). The reason category list should be configurable by workspace admins.
