---
id: US-043
title: "Anomaly Severity Classification"
slug: "anomaly-severity-classification"
personas: [P-006, P-002, P-004, P-008]
epic: "Anomaly Detection"
priority: "must-have"
complexity: "M"
tags: [anomaly-detection, severity, classification, triage, prioritization]
---

# US-043: Anomaly Severity Classification

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** have anomalies automatically classified into severity levels (informational, warning, critical),
**So that** my team can triage and respond to the most impactful issues first without manually reviewing every anomaly signal.

## Acceptance Criteria

- [ ] Given an anomaly is detected, when it is scored and classified, then it is assigned one of three severity levels: Informational (score 0–39), Warning (40–69), Critical (70–100), based on configurable score thresholds
- [ ] Given I am a workspace administrator, when I configure severity thresholds, then I can adjust the score boundaries per device group to match operational risk tolerance
- [ ] Given a Critical anomaly is generated, when it appears in the Outcome Dashboard, then it is visually distinguished (color, icon, sort order) from Warning and Informational events
- [ ] Given a playbook condition references anomaly severity (from US-028), when a Critical anomaly occurs on a matched device, then the condition evaluates to true and the playbook fires
- [ ] Given an Informational anomaly, when it escalates in score within a 15-minute window to Critical, then the severity level updates in real time and any severity-based playbooks are re-evaluated

## Notes

Severity thresholds should have sensible defaults that most operators can use without customization. Severity level is the primary field referenced by playbook conditions (US-028) and notification preferences (US-047). Depends on US-040 for the underlying composite score.
